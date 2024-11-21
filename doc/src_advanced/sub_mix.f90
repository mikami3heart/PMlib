
module data_type
real(kind=2),allocatable :: a2h(:,:), b2h(:,:), c2h(:,:)
real(kind=4),allocatable :: a2s(:,:), b2s(:,:), c2s(:,:)
real(kind=8),allocatable :: a2d(:,:), b2d(:,:), c2d(:,:)
real(kind=2) r_half
real(kind=4) r_single
real(kind=8) r_double
end module data_type

subroutine sub_init(n)
use data_type
integer :: n
real(kind=8), parameter :: PAI=3.14159265358979
allocate( a2h(n,n), b2h(n,n), c2h(n,n) )
allocate( a2s(n,n), b2s(n,n), c2s(n,n) )
allocate( a2d(n,n), b2d(n,n), c2d(n,n) )

!$omp parallel do private(i,j,angle)
do i=1,n
do j=1,n
angle=PAI*real(j-1)/real(n)
a2d(j,i)=sin(angle) ; b2d(j,i)=cos(angle) ; c2d(j,i)=0.0
a2s(j,i)=a2d(j,i) ; b2s(j,i)=b2d(j,i) ; c2s(j,i)=0.0
a2h(j,i)=a2s(j,i) ; b2h(j,i)=b2s(j,i) ; c2h(j,i)=0.0
end do
end do
!$omp end parallel do

return
end subroutine

subroutine sub_dmix(n)
use data_type
integer :: n
!$omp parallel do private(i,j,k)
do k=1,n
do j=1,n
do i=1,n
c2d(i,j) = c2d(i,j) + a2d(i,k)*b2d(k,j)
end do
end do
end do
!$omp end parallel do
r_double = c2d(1,n) + c2d(n,1)
return
end subroutine

subroutine sub_smix(n)
use data_type
integer :: n
!$omp parallel do private(i,j,k)
do k=1,n
do j=1,n
do i=1,n
c2s(i,j) = c2s(i,j) + a2s(i,k)*b2s(k,j)
end do
end do
end do
!$omp end parallel do
r_single = c2s(1,n) + c2s(n,1)
return
end subroutine

subroutine sub_hmix(n)
use data_type
integer :: n
!$omp parallel do private(i,j,k)
do k=1,n
do j=1,n
do i=1,n
c2h(i,j) = c2h(i,j) + a2h(i,k)*b2h(k,j)
end do
end do
end do
!$omp end parallel do
r_half = c2h(1,n) + c2h(n,1)
return
end subroutine
