#ifndef _PM_PERFMONITOR_H_
#define _PM_PERFMONITOR_H_

/*
###################################################################################
#
# PMlib - Performance Monitor Library
#
# Copyright (c) 2010-2011 VCAD System Research Program, RIKEN.
# All rights reserved.
#
# Copyright (c) 2012-2020 Advanced Institute for Computational Science(AICS), RIKEN.
# All rights reserved.
#
# Copyright (c) 2016-2020 Research Institute for Information Technology(RIIT), Kyushu University.
# All rights reserved.
#
###################################################################################
 */

//! @file   PerfMonitor.h
//! @brief  PerfMonitor class Header
//! @version rev.6.3

#ifdef DISABLE_MPI
#include "mpi_stubs.h"
#else
#include <mpi.h>
#endif

#include "PerfWatch.h"
#include <cstdio>
#include <cstdlib>
#include "pmVersion.h"
#include <map>
#include <list>


namespace pm_lib {

  /**
   * 計算性能測定管理クラス.
   */
  class PerfMonitor {
  public:

    /// 測定計算量のタイプ
    enum Type {
      COMM,  ///< 通信（あるいはメモリ転送）
      CALC,  ///< 演算
    };

  private:
    int num_process;           ///< 並列プロセス数
    int num_threads;           ///< 並列スレッド数
    int my_rank;               ///< 自ランク番号
    int m_nWatch;              ///< 測定区間数
    int init_nWatch;           ///< 初期に確保する測定区間数
    int reserved_nWatch;       ///< リザーブ済みの測定区間数

    bool is_MPI_enabled;       ///< PMlibの対応動作可能フラグ:MPI
    bool is_OpenMP_enabled;	   ///< PMlibの対応動作可能フラグ:OpenMP
    bool is_PAPI_enabled;      ///< PMlibの対応動作可能フラグ:PAPI
    bool is_OTF_enabled;       ///< 対応動作可能フラグ:OTF tracing 出力
    bool is_PMlib_enabled;     ///< PMlibの動作を有効にするフラグ
    bool is_Root_active;       ///< 背景区間(Root区間)の動作フラグ
    bool is_exclusive_construct; ///< 測定区間の重なり状態検出フラグ

    std::string parallel_mode; ///< 並列動作モード
      // {"Serial", "OpenMP", "FlatMPI", "Hybrid"}
    std::string env_str_hwpc;  ///< 環境変数HWPC_CHOOSERの値
      // "USER" or one of the followings
      // "FLOPS", "BANDWIDTH", "VECTOR", "CACHE", "CYCLE", "WRITEBACK"
    PerfWatch* m_watchArray;   ///< 測定区間の配列
      // PerfWatchのインスタンスは全部で m_nWatch 生成され、その番号対応は以下
      // m_watchArray[0]  :PMlibが定義するRoot区間
      // m_watchArray[1 .. m_nWatch] :ユーザーが定義する各区間
    unsigned* m_order;         ///< 測定区間ソート用のリストm_order[m_nWatch]

  public:
    /// コンストラクタ.
    PerfMonitor() : m_watchArray(0) {}

    /// デストラクタ.
    ~PerfMonitor() {
	#ifdef DEBUG_PRINT_MONITOR
		fprintf(stderr, "\t <PerfMonitor> rank %d destructor is called\n", my_rank);
	#endif
		if (m_watchArray) delete[] m_watchArray;
		if (m_order) delete[] m_order;
	}


    /// PMlibの内部初期化
    ///
    /// 測定区間数分の内部領域を確保しする。並列動作モード、サポートオプション
    /// の認識を行い、実行時のオプションによりHWPC、OTF出力用の初期化も行う。
    ///
    /// @param[in] init_nWatch 最初に確保する測定区間数（C++では省略可能）
    ///
    /// @note
    /// 測定区間数分の内部領域を最初にinit_nWatch区間分を確保する。
    /// 測定区間数が不足したらその都度動的にinit_nWatch追加する。
    ///
    void initialize (int init_nWatch=100);


    /// 測定区間とそのプロパティを設定.
    ///
    ///   @param[in] label 測定区間に与える名前の文字列
    ///   @param[in] type  測定計算量のタイプ(COMM:通信, CALC:演算)
    ///   @param[in] exclusive 排他測定フラグ。bool型(省略時true)、
    ///                        Fortran仕様は整数型(0:false, 1:true)
    ///
    ///   @note labelラベル文字列は測定区間を識別するために用いる。
    ///   各ラベル毎に対応した区間番号を内部で自動生成する
    ///   最初に確保した区間数init_nWatchが不足したら動的にinit_nWatch追加する
    ///   第１引数は必須。第２引数は明示的な自己申告モードの場合に必須。
    ///   第３引数は省略可
    ///
    void setProperties(const std::string& label, Type type=CALC, bool exclusive=true);


    /// 測定区間スタート
    ///
    ///   @param[in] label ラベル文字列。測定区間を識別するために用いる。
    ///
    ///
    void start (const std::string& label);


    /// 測定区間ストップ
    ///
    ///   @param[in] label ラベル文字列。測定区間を識別するために用いる。
    ///   @param[in] flopPerTask 測定区間の計算量(演算量Flopまたは通信量Byte) :省略値0
    ///   @param[in] iterationCount  計算量の乗数（反復回数）:省略値1
    ///
    ///   @note  引数はユーザ申告モードの場合にのみ利用される。 \n
    ///   @note  測定区間の計算量は次のように算出される。 \n
    ///          (A) ユーザ申告モードの場合は １区間１回あたりで flopPerTask*iterationCount \n
    ///          (B) HWPCによる自動算出モードの場合は引数とは関係なくHWPC内部値を利用\n
    ///   @note  HWPC APIが利用できないシステムや環境変数HWPC_CHOOSERが指定
    ///          されていないジョブでは自動的にユーザ申告モードで実行される。\n
    ///   @note  出力レポートに表示される計算量は測定のモード・引数の
    ///          組み合わせで以下の規則により決定される。 \n
    ///   @verbatim
    /**
    (A) ユーザ申告モード
      - ユーザ申告モードでは(1)setProperties() と(2)stop()への引数により出力内容が決定される。
        (1) setProperties(区間名, type, exclusive)の第2引数typeが計算量のタイプを指定する。
        (2) stop (区間名, fPT, iC)の第2引数fPTは計算量（浮動小数点演算、データ移動)を指定する。
      - ユーザ申告モードで 計算量の引数が省略された場合は時間のみレポート出力する。

    (B) HWPCによる自動算出モード
      - HWPC/PAPIが利用可能なプラットフォームで利用できる
      - 環境変数HWPC_CHOOSERの値により測定情報を選択する。(FLOPS| BANDWIDTH| VECTOR| CACHE| CYCLE| WRITEBACK)

    ユーザ申告モードかHWPC自動算出モードかは、内部的に下記表の組み合わせで決定される。

    環境変数     setProperties()  stop()
    HWPC_CHOOSER   type引数      fP引数      基本・詳細レポート出力      HWPC詳細レポート出力
    -----------------------------------------------------------------------------------------
    USER (無指定)   CALC         指定値      時間、fP引数によるFlops     なし
    USER (無指定)   COMM         指定値      時間、fP引数によるByte/s    なし
    FLOPS           無視         無視        時間、HWPC自動計測Flops     FLOPSに関連するHWPC統計情報
    VECTOR          無視         無視        時間、HWPC自動計測SIMD率    VECTORに関連するHWPC統計情報
    BANDWIDTH       無視         無視        時間、HWPC自動計測Byte/s    BANDWIDTHに関連するHWPC統計情報
    CACHE           無視         無視        時間、HWPC自動計測L1$,L2$   CACHEに関連するHWPC統計情報
    CYCLE           無視         無視        時間、HWPC自動計測cycle     CYCLEに関連するHWPC統計情報
    WRITEBACK       無視         無視        時間、HWPC自動計測Byte/s    MEM(WRITE)に関するHWPC統計情報
     **/
    ///   @endverbatim
    ///
    void stop(const std::string& label, double flopPerTask=0.0, unsigned iterationCount=1);


    /// 測定区間のリセット
    ///
    ///   @param[in] label ラベル文字列。測定区間を識別するために用いる。
    ///
    void reset (const std::string& label);


    /// 全測定区間のリセット
    ///
    ///
    void resetAll (void);


    /// 全プロセスの測定結果、全スレッドの測定結果を集約
    /// 利用者は通常このAPIを呼び出す必要はない。
    ///
    /// @note  以下の処理を行う。
    ///       各測定区間の全プロセスの測定結果情報をマスタープロセスに集約。
    ///       測定結果の平均値・標準偏差などの基礎的な統計計算。
    ///       経過時間でソートした測定区間のリストm_order[m_nWatch] を作成する。
    ///       各測定区間のHWPCイベントの統計値を取得する。
    ///       各プロセスの全スレッド測定結果をマスタースレッドに集約
    ///		通常はこのAPIはPMlib内部で自動的に実行される
    ///
    void gather(void);


    ///  OpenMP並列処理されたPMlibスレッド測定区間のうち parallel regionから
    ///  呼び出された測定区間のスレッド測定情報をマスタースレッドに集約する。
    ///  通常このAPIはPMlib内部で自動的に実行され、利用者が呼び出す必要はない。
    ///
    ///   @note  内部で全測定区間をcheckして該当する測定区間を選択する。
    ///
    void mergeThreads(void);


    /// 測定結果の基本統計レポートを出力。
    ///   排他測定区間毎に出力。プロセスの平均値、ジョブ全体の統計値も出力。
    ///
    ///   @param[in] fp       出力ファイルポインタ
    ///   @param[in] hostname ホスト名(省略時はrank 0 実行ホスト名)
    ///   @param[in] comments 任意のコメント
    ///   @param[in] op_sort    測定区間の表示順 (0:経過時間順、1:登録順)
    ///
    ///   @note 基本統計レポートは排他測定区間, 非排他測定区間をともに出力する。
    ///      MPIの場合、rank0プロセスの測定回数が１以上の区間のみを表示する。
    ///   @note  内部では以下の処理を行う。
    ///      各測定区間の全プロセス途中経過状況を集約。 gather_and_stats();
    ///      測定結果の平均値・標準偏差などの基礎的な統計計算。
    ///      経過時間でソートした測定区間のリストm_order[m_nWatch] を作成する。
    ///      各測定区間のHWPCイベントの統計値を取得する。
    ///
    void print(FILE* fp, const std::string hostname, const std::string comments, int op_sort=0);


    /// MPIランク別詳細レポート、HWPC詳細レポートを出力。
    ///
    ///   @param[in] fp       出力ファイルポインタ
    ///   @param[in] legend   HWPC 記号説明の表示 (0:なし、1:表示する)
    ///   @param[in] op_sort    測定区間の表示順 (0:経過時間順、1:登録順)
    ///
    ///   @note 詳細レポートは排他測定区間のみを出力する
    ///
    void printDetail(FILE* fp, int legend=0, int op_sort=0);


    /// 指定プロセスに対してスレッド別詳細レポートを出力。
    ///
    ///   @param[in] fp	       出力ファイルポインタ
    ///   @param[in] rank_ID   出力対象プロセスのランク番号
    ///   @param[in] op_sort     測定区間の表示順 (0:経過時間順、1:登録順)
    ///
    void printThreads(FILE* fp, int rank_ID=0, int op_sort=0);


    /// HWPC 記号の説明表示を出力。
    ///
    ///   @param[in] fp 出力ファイルポインタ
    ///
    void printLegend(FILE* fp);


    /// プロセスグループ単位でのMPIランク別詳細レポート、HWPC詳細レポート出力
    ///
    ///   @param[in] fp 出力ファイルポインタ
    ///   @param[in] p_group  MPI_Group型 groupのgroup handle
    ///   @param[in] p_comm   MPI_Comm型 groupに対応するcommunicator
    ///   @param[in] pp_ranks int*型 groupを構成するrank番号配列へのポインタ
    ///   @param[in] group  int型 (省略可)プロセスグループ番号
    ///   @param[in] legend int型 (省略可)HWPC記号説明の表示(0:なし、1:表示する)
    ///   @param[in] op_sort int型 (省略可)測定区間の表示順 (0:経過時間順、1:登録順)
    ///
    ///   @note プロセスグループはp_group によって定義され、p_groupの値は
    ///   MPIライブラリが内部で定める大きな整数値を基準に決定されるため、
    ///   利用者にとって識別しずらい場合がある。
    ///   別に1,2,3,..等の昇順でプロセスグループ番号 groupをつけておくと
    ///   レポートが識別しやすくなる。
    ///
    void printGroup(FILE* fp, MPI_Group p_group, MPI_Comm p_comm, int* pp_ranks, int group=0, int legend=0, int op_sort=0);


    /// MPI communicatorから自動グループ化したMPIランク別詳細レポート、HWPC詳細レポートを出力
    ///
    ///   @param[in] fp 出力ファイルポインタ
    ///   @param[in] p_comm   MPI_Comm型 MPI_Comm_split()で対応つけられたcommunicator
    ///   @param[in] icolor int型 MPI_Comm_split()のカラー変数
    ///   @param[in] key    int型 MPI_Comm_split()のkey変数
    ///   @param[in] legend int型 (省略可)HWPC記号説明の表示(0:なし、1:表示する)
    ///   @param[in] op_sort int型 (省略可)測定区間の表示順 (0:経過時間順、1:登録順)
    ///
    void printComm (FILE* fp, MPI_Comm p_comm, int icolor, int key, int legend=0, int op_sort=0);


    /// 測定途中経過の状況レポートを出力（排他測定区間を対象とする）
    ///
    ///   @param[in] fp       出力ファイルポインタ
    ///   @param[in] comments 任意のコメント
    ///   @param[in] op_sort 測定区間の表示順 (0:経過時間順、1:登録順)
    ///
    ///   @note 基本レポートと同様なフォーマットで途中経過を出力する。
    ///      多数回の反復計算を行う様なプログラムにおいて初期の経過状況を
    ///      モニターする場合などに有効に用いることができる。
    ///
    void printProgress(FILE* fp, const std::string comments, int op_sort=0);


    /// ポスト処理用traceファイルの出力
    ///
    /// @note プログラム実行中一回のみポスト処理用traceファイルを出力できる
    /// 現在サポートしているフォーマットは OTF(Open Trace Format) v1.1
    ///
    void postTrace(void);


    /// 旧バージョンとの互換維持用(並列モードを設定)。
    /// 利用者は通常このAPIを呼び出す必要はない。
    ///
    /// @param[in] p_mode 並列モード
    /// @param[in] n_thread
    /// @param[in] n_proc
    ///
    /// @note 並列モードはPMlib内部で自動的に識別可能なため、
    ///       利用者は通常このAPIを呼び出す必要はない。
    ///
    void setParallelMode(const std::string& p_mode, const int n_thread, const int n_proc);

    /// 旧バージョンとの互換維持用(ランク番号の通知)
    /// 利用者は通常このAPIを呼び出す必要はない。
    ///
    /// @param[in] my_rank_ID   MPI process ID
    ///
    /// @note ランク番号はPMlib内部で自動的に識別される。
    /// @note 並列モードはPMlib内部で自動的に識別可能なため、
    ///       利用者は通常このAPIを呼び出す必要はない。
    ///
    void setRankInfo(const int my_rank_ID) {
      //	my_rank = my_rank_ID;
    }

    /// 旧バージョンとの互換維持用(PMlibバージョン番号の文字列を返す)
    /// 利用者は通常このAPIを呼び出す必要はない。
    ///
    std::string getVersionInfo(void);


  private:

    std::map<std::string, int > array_of_symbols;

    /// 測定区間のラベルに対応する区間番号を追加作成する
    ///
    ///   @param[in] arg_st   測定区間のラベル
    ///
    int add_perf_label(std::string arg_st)
    {
		int ip = m_nWatch;
    	// perhaps it is better to return ip showing the insert status.
		// sometime later...
    	array_of_symbols.insert( make_pair(arg_st, ip) );
	#ifdef DEBUG_PRINT_LABEL
    	fprintf(stderr, "<add_perf_label> [%s] &array_of_symbols(%p) [%d] \n",
    		arg_st.c_str(), &array_of_symbols, ip);
	#endif
    	return ip;
    }

    /// 測定区間のラベルに対応する区間番号を取得
    ///
    ///   @param[in] arg_st   測定区間のラベル
    ///
    int find_perf_label(std::string arg_st)
    {
    	int p_id;
    	if (array_of_symbols.find(arg_st) == array_of_symbols.end()) {
    		p_id = -1;
    	} else {
    		p_id = array_of_symbols[arg_st] ;
    	}
		#ifdef DEBUG_PRINT_LABEL
    	//fprintf(stderr, "<find_perf_label> %s : %d\n", arg_st.c_str(), p_id);
		#endif
    	return p_id;
    }

    /// 測定区間の区間番号に対応するラベルを取得
    ///
    ///   @param[in] ip 測定区間の区間番号
    ///   @param[in] p_label ラベルとなる文字列
    ///
    void loop_perf_label(const int ip, std::string& p_label)
    {
	std::map<std::string, int>::const_iterator it;
	int p_id;

	for(it = array_of_symbols.begin(); it != array_of_symbols.end(); ++it) {
		p_label = it->first;
		p_id = it->second;
		if (p_id == ip) {
			return;
		}
	}
	// should not reach here
	fprintf(stderr, "<loop_perf_label> p_label search failed. ip=%d\n", ip);
    }

    /// 全測定区間のラベルと番号を登録順で表示
    ///
    void check_all_perf_label(void)
    {
	std::map<std::string, int>::const_iterator it;
	std::string p_label;
	int p_id;
	fprintf(stderr, "\t<check_all_perf_label> map: label, value\n");
	for(it = array_of_symbols.begin(); it != array_of_symbols.end(); ++it) {
		p_label = it->first;
		p_id = it->second;
		fprintf(stderr, "\t\t <%s> : %d\n", p_label.c_str(), p_id);
	}
    }

    /// 全プロセスの測定中経過情報を集約
    ///
    ///   @note  以下の処理を行う。
    ///    各測定区間の全プロセス途中経過状況を集約。
    ///    測定結果の平均値・標準偏差などの基礎的な統計計算。
    ///    各測定区間のHWPCイベントの統計値を取得する。
    void gather_and_stats(void);

    /// 経過時間でソートした測定区間のリストm_order[m_nWatch] を作成する。
    ///
    void sort_m_order(void);

    /// 基本統計レポートのヘッダ部分を出力。
    ///
    ///   @param[in] fp       出力ファイルポインタ
    ///   @param[in] hostname ホスト名(省略時はrank 0 実行ホスト名)
    ///   @param[in] comments 任意のコメント
    ///   @param[in] tot      測定経過時間
    ///
    void printBasicHeader(FILE* fp, const std::string hostname, const std::string comments, double tot=0.0);

    /// 基本統計レポートの各測定区間を出力
    ///
    ///   @param[in] fp        出力ファイルポインタ
    ///   @param[in] maxLabelLen    ラベル文字長
    ///   @param[in] tot       全経過時間
    ///   @param[in] sum_time_flop  演算経過時間
    ///   @param[in] sum_time_comm  通信経過時間
    ///   @param[in] sum_time_other  その他経過時間
    ///   @param[in] sum_flop  演算量
    ///   @param[in] sum_comm  通信量
    ///   @param[in] sum_other その他
    ///   @param[in] unit      計算量の単位
    ///   @param[in] op_sort     測定区間の表示順 (0:経過時間順、1:登録順)
    ///
    ///   @note   計算量（演算数やデータ移動量）選択方法は PerfWatch::stop() の
    ///           コメントに詳しく説明されている。
    ///
    void printBasicSections(FILE* fp, int maxLabelLen, double& tot,
              double& sum_flop, double& sum_comm, double& sum_other,
              double& sum_time_flop, double& sum_time_comm, double& sum_time_other,
              std::string unit, int op_sort=0);

    /// 基本統計レポートのテイラー部分を出力。
    ///
    ///   @param[in] fp       出力ファイルポインタ
    ///   @param[in] maxLabelLen    ラベル文字長
    ///   @param[in] sum_time_flop  演算経過時間
    ///   @param[in] sum_time_comm  通信経過時間
    ///   @param[in] sum_time_other  その他経過時間
    ///   @param[in] sum_flop  演算量
    ///   @param[in] sum_comm  通信量
    ///   @param[in] sum_other  その他
    ///   @param[in] unit 計算量の単位
    ///
    void printBasicTailer(FILE* fp, int maxLabelLen,
              double sum_flop, double sum_comm, double sum_other,
              double sum_time_flop, double sum_time_comm, double sum_time_other,
              const std::string unit);

    /// PerfMonitorクラス用エラーメッセージ出力
    ///
    ///   @param[in] func  関数名
    ///   @param[in] fmt  出力フォーマット文字列
    ///
    void printDiag(const char* func, const char* fmt, ...)
    {
      if (my_rank == 0) {
        fprintf(stderr, "*** PMlib message. PerfMonitor::%s: ", func );
        va_list ap;
        va_start(ap, fmt);
        vfprintf(stderr, fmt, ap);
        va_end(ap);
      }
    }

  }; // end of class PerfMonitor //

} /* namespace pm_lib */

#endif // _PM_PERFMONITOR_H_

