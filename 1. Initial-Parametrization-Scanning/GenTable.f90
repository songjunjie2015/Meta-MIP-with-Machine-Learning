program Gen_table
implicit none
integer          :: nbins,i,pt
real, parameter  :: delr=0.002
double precision :: r,f(2),g(2),Rc,ep,R0,C4
open(unit=1,file='table.xvg',status='unknown',action='write')
write(*,'(a87)') 'Input parameters: Epsilon,Rmin,C4,Rcutoff; and potential type (1=LJ12-6, 2=LJ12-6-4)'
read(*,*) ep,R0,C4,Rc,pt
write(*,'(4f10.5,i2)') ep,R0,C4,Rc,pt
if ( pt .eq. 2 ) then
    ep=ep*4.1858518
    R0=R0*0.200000
    C4=C4*0.0004184
end if
write(1,'(7e15.6)') 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
nbins=int((Rc+1)/delr)+1
do i=1,nbins
    r=delr*i
    if ( pt .eq. 1 ) then
        f(1) = 4 * ep * ( R0**12/r**12 - R0**6/r**6 )
        f(2) = 24 * ep * ( 2*R0**12/r**13 - R0**6/r**7 )
    else if ( pt .eq. 2 ) then
        f(1) = ep * ( R0**12/r**12 - 2*R0**6/r**6 ) - C4/r**4
        f(2) = ep * ( 12*R0**12/r**13 - 12*R0**6/r**7 ) - 4*C4/r**5
    else
        write(*,*) 'Error: potential type can only be 1 or 2 !'
        stop
    end if
    write(1,'(7e15.6)') r, 1/r, 1/(r*r), f(1), f(2), f(1), f(2)
end do
close(1)
end program Gen_table
