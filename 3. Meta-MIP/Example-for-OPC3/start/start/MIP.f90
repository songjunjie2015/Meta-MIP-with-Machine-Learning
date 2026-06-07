module all
integer, parameter :: nDIMmax=6
integer, parameter :: nGRIDs=5
integer            :: npoints(nDIMmax),npoints_mip(nDIMmax)
double precision   :: para_max(nDIMmax),para_min(nDIMmax)
double precision   :: dist(nDIMmax),dist_mip(nDIMmax)
double precision   :: para(nDIMmax,nGRIDs**nDIMmax),para_mip(nDIMmax)
double precision,allocatable :: dim_trans(:,:,:,:,:,:,:),prop(:,:)
end


program mipnm
use all
implicit none
integer                      :: i,j,k,L,n,i1,i2,i3,i4,i5,i6,ntotal,ierror,mode,nDIM,nPROP,iPROP,id(nDIMmax)
double precision             :: prop_mip,bool_error,ave_error
character                    :: c200*200 ,inname*200 ,outname*200
double precision,allocatable :: prop_set(:),error_set(:),error_mip(:)

write(*,*) 'nDIM,nPROP'
read(*,*) nDIM,nPROP

allocate (dim_trans(nPROP,nGRIDs,nGRIDs,nGRIDs,nGRIDs,nGRIDs,nGRIDs))
allocate (prop(nPROP,nGRIDs**nDIMmax),prop_set(nPROP),error_set(nPROP),error_mip(nPROP))

write(*,*) 'inname='
read(*,'(a200)') inname
write(*,*) 'outname='
read(*,'(a200)') outname
open(unit=1,file=trim(adjustl(inname)),status='old',action='read')
open(unit=2,file=trim(adjustl(outname)),status='unknown',action='write') 
 
ntotal=0
dist=100.
para_max=0.0
para_min=10000.0
do while(.true.)
read(1,'(a200)',iostat=ierror) c200
if (ierror/=0 .or. len_trim(c200) .eq. 0)  exit
if (index(c200,'req') .eq. 0) then
ntotal=ntotal+1    
read(c200,*) para(1:nDIM,ntotal),prop(:,ntotal)
do i=1,nDIM
if (para(i,ntotal) .gt. para_max(i)) para_max(i)=para(i,ntotal)
if (para(i,ntotal) .lt. para_min(i)) para_min(i)=para(i,ntotal)    
if  (abs(para(i,ntotal)-para(i,1)) .lt. dist(i) .and. abs(para(i,ntotal)-para(i,1)) .gt. 0.0) then
dist(i)=abs(para(i,ntotal)-para(i,1))   
end if
end do
end if
end do
close(1)

where(dist(:) .eq. 100.)  dist(:)=0
where(dist(:) .ne. 0) npoints(:)=nint((para_max(:)-para_min(:))/dist(:))+1
where(dist(:) .eq. 0) npoints(:)=1

dim_trans=0.0
id=1
do i=1,ntotal
do j=1,ndim
if (dist(j).ne.0)  id(j)= nint((para(j,i)-(para_min(j)))/dist(j))+1
end do
dim_trans(:,id(1),id(2),id(3),id(4),id(5),id(6))=prop(:,i)
end do

write(*,'(a6,20f8.3)') 'dist: ',dist(1:ndim)
write(*,'(a6,20f8.3)') 'max: ',para_max(1:ndim)
write(*,'(a6,20f8.3)') 'min: ',para_min(1:ndim)
write(*,'(a6,20i8)')   'nps: ',npoints(1:ndim)


write(*,*) '1=screen 2=not screen'
read(*,*) mode

if (mode .eq. 1) then
write(*,*) 'What are your prop(:) and allowed error(:)'
read(*,*) prop_set(:),error_set(:)
end if

write(*,*) 'The new points(:) =:'
npoints_mip=1
read(*,*) npoints_mip(1:nDIM)

do i=1,6
if (npoints_mip(i).ne.1) dist_mip(i)=(npoints(i)-1)*dist(i)/(npoints_mip(i)-1)
if (npoints_mip(i).eq.1) dist_mip(i)=0.0
end do


do i1=1, npoints_mip(1)
para_mip(1)=   para_min(1) +(i1-1)*dist_mip(1)
do i2=1, npoints_mip(2)
para_mip(2)=   para_min(2) +(i2-1)*dist_mip(2)
do i3=1, npoints_mip(3)
para_mip(3)=   para_min(3) +(i3-1)*dist_mip(3)
do i4=1, npoints_mip(4)
para_mip(4)=   para_min(4) +(i4-1)*dist_mip(4)
do i5=1, npoints_mip(5)
para_mip(5)=   para_min(5) +(i5-1)*dist_mip(5)
do i6=1, npoints_mip(6)
para_mip(6)=   para_min(6) +(i6-1)*dist_mip(6)
bool_error=0.
ave_error=0.
do i=1,nPROP
error_mip(i)=abs(prop_mip(i)-prop_set(i))/abs(prop_set(i))
bool_error=bool_error+sign(1.,error_mip(i)-error_set(i))
ave_error=ave_error+error_mip(i)/nPROP
end do
if ( mode .eq. 1 .and. nint(bool_error) .eq. -nPROP) write(2,'(30f15.6)') para_mip(1:ndim),(prop_mip(iPROP),iPROP=1,nPROP),error_mip(:),ave_error  
if ( mode .eq. 2)                                    write(2,'(30f15.6)') para_mip(1:ndim),(prop_mip(iPROP),iPROP=1,nPROP) 
end do
end do
end do
end do
end do
end do

deallocate (dim_trans,prop,prop_set,error_set,error_mip)

end
    
function prop_mip(iPROP)
use all
implicit none
integer            :: i,j,k,iPROP
integer            :: i1,i2,i3,i4,i5,i6
integer            :: f1,f2,f3,f4,f5,f6
double precision   :: w(nDIMmax),position(nDIMmax),prop_mip,weight_mip

do i=1,nDIMmax
position(i)=1.0
w(i)=0.0
if (dist(i).ne.0) then
position(i)=  (para_mip(i)-para_min(i)) /dist(i)+1
w(i)=(position(i)-int(position(i)))
if (position(i) .eq. int(position(i))) w(i)=0.0
end if
end do

i1=int(position(1))
i2=int(position(2))
i3=int(position(3))
i4=int(position(4))
i5=int(position(5))
i6=int(position(6))
prop_mip=0.
do f6=0,1,1
do f5=0,1,1
do f4=0,1,1
do f3=0,1,1
do f2=0,1,1
do f1=0,1,1
weight_mip=             ((-1)**(f6+1)  *  w(6)  +  (1-f6))
weight_mip=weight_mip*  ((-1)**(f5+1)  *  w(5)  +  (1-f5)) 
weight_mip=weight_mip*  ((-1)**(f4+1)  *  w(4)  +  (1-f4))
weight_mip=weight_mip*  ((-1)**(f3+1)  *  w(3)  +  (1-f3))
weight_mip=weight_mip*  ((-1)**(f2+1)  *  w(2)  +  (1-f2))
weight_mip=weight_mip*  ((-1)**(f1+1)  *  w(1)  +  (1-f1))
prop_mip=prop_mip+weight_mip*dim_trans(iPROP,i1+f1,i2+f2,i3+f3,i4+f4,i5+f5,i6+f6)
weight_mip=1.
end do
end do
end do
end do
end do
end do

end
