program R0_CN
implicit none
integer    :: ierror
character  :: RDFnam*80,RCNnam*80
real       :: RDFdat(2),RCNdat(2),start(3),sift(6)
write(*,*) 'Input the .dat files of RDF and CN'
read(*,*) RDFnam, RCNnam
if (index(RDFnam,'.dat') .eq. 0) RDFnam=trim(RDFnam)//'.dat'
if (index(RCNnam,'.dat') .eq. 0) RCNnam=trim(RCNnam)//'.dat'
open(unit=1,file=trim(adjustl(RDFnam)),status='old',action='read')
do while (.True.)
read(1,*,iostat=ierror) RDFdat(1),RDFdat(2)
if (ierror/=0) exit
  if ( RDFdat(2) .ne. 0 ) then
    start(1) = RDFdat(1)
    exit
  end if
end do
close(1)
sift = 0.0
open(unit=1,file=trim(adjustl(RDFnam)),status='old',action='read')
do while (.True.)
read(1,*,iostat=ierror) RDFdat(1),RDFdat(2)
if (ierror/=0) exit
    if ( RDFdat(2) .gt. sift(2) ) then
    sift(1) = RDFdat(1)
    sift(2) = RDFdat(2)
    end if
end do
close(1)
start(2) = 4*sift(1) - 3*start(1)
open(unit=1,file=trim(adjustl(RDFnam)),status='old',action='read')
do while (.True.)
read(1,*,iostat=ierror) RDFdat(1),RDFdat(2)
if (ierror/=0) exit
  if ( ( RDFdat(1) .gt. start(2) ) .and. ( ( RDFdat(2) .gt. sift(4) ) ) ) then
    sift(3) = RDFdat(1)
    sift(4) = RDFdat(2)
  end if
end do
close(1)
start(3) = 0.5 * (sift(1)+sift(3))
open(unit=2,file=trim(adjustl(RCNnam)),status='old',action='read')
do while (.True.)
read(2,*,iostat=ierror) RCNdat(1),RCNdat(2)
if (ierror/=0) exit
  if ( RCNdat(1) .ge. start(3) ) then
  sift(5) = RCNdat(1)
  sift(6) = RCNdat(2)
  exit
  end if
end do
close(2)
write(*,*) 'Peak1 Height1     Peak2 Height2     Valley CN'
write(*,'(6f9.4)') sift(1),sift(2),sift(3),sift(4),sift(5),sift(6)
end program R0_CN
