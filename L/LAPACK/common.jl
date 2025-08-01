using BinaryBuilder, Pkg

# LAPACK mirrors the OpenBLAS build, whereas LAPACK32 mirrors the OpenBLAS32 build.

version = v"3.12.1"

# Collection of sources required to build lapack
sources = [
    GitSource("https://github.com/Reference-LAPACK/lapack",
              "6ec7f2bc4ecf4c4a93496aa2fa519575bc0e39ca"),
]

# Bash recipe for building across all platforms

function lapack_script(;lapack32::Bool=false)
    script = """
    LAPACK32=$(lapack32)
    """

    script *= raw"""
    cd $WORKSPACE/srcdir/lapack*

    if [[ "${target}" == *-mingw* ]]; then
        BLAS="blastrampoline-5"
    else
        BLAS="blastrampoline"
    fi

    FFLAGS=-ffixed-line-length-none
    if [[ ${nbits} == 64 ]] && [[ "${LAPACK32}" != "true" ]]; then
      FFLAGS="${FFLAGS} -cpp -DUSE_ISNAN -fdefault-integer-8"

      syms=(
        CAXPBY CAXPY CBBCSD CBDSQR CCOPY CDOTC CDOTU CGBBRD CGBCON CGBEQU
        CGBEQUB CGBMV CGBRFS CGBSV CGBSVX CGBTF2 CGBTRF CGBTRS CGEADD CGEBAK
        CGEBAL CGEBD2 CGEBRD CGECON CGEDMD CGEDMDQ CGEEQU CGEEQUB CGEES CGEESX
        CGEEV CGEEVX CGEHD2 CGEHRD CGEJSV CGELQ CGELQ2 CGELQF CGELQT CGELQT3
        CGELS CGELSD CGELSS CGELST CGELSY CGEMLQ CGEMLQT CGEMM CGEMM3M CGEMQR
        CGEMQRT CGEMV CGEQL2 CGEQLF CGEQP3 CGEQP3RK CGEQR CGEQR2 CGEQR2P
        CGEQRF CGEQRFP CGEQRT CGEQRT2 CGEQRT3 CGERC CGERFS CGERQ2 CGERQF CGERU
        CGESC2 CGESDD CGESV CGESVD CGESVDQ CGESVDX CGESVJ CGESVX CGETC2 CGETF2
        CGETRF CGETRF2 CGETRI CGETRS CGETSLS CGETSQRHRT CGGBAK CGGBAL CGGES
        CGGES3 CGGESX CGGEV CGGEV3 CGGEVX CGGGLM CGGHD3 CGGHRD CGGLSE CGGQRF
        CGGRQF CGGSVD3 CGGSVP3 CGSVJ0 CGSVJ1 CGTCON CGTRFS CGTSV CGTSVX CGTTRF
        CGTTRS CGTTS2 CHB2ST_KERNELS CHB2ST_KERNELS CHBEV CHBEV_2STAGE
        CHBEV_2STAGE CHBEVD CHBEVD_2STAGE CHBEVD_2STAGE CHBEVX CHBEVX_2STAGE
        CHBEVX_2STAGE CHBGST CHBGV CHBGVD CHBGVX CHBMV CHBTRD CHECON CHECON_3
        CHECON_3 CHECON_ROOK CHECON_ROOK CHEEQUB CHEEV CHEEV_2STAGE CHEEV_2STAGE
        CHEEVD CHEEVD_2STAGE CHEEVD_2STAGE CHEEVR CHEEVR_2STAGE CHEEVR_2STAGE
        CHEEVX CHEEVX_2STAGE CHEEVX_2STAGE CHEGS2 CHEGST CHEGV CHEGV_2STAGE
        CHEGV_2STAGE CHEGVD CHEGVX CHEMM CHEMV CHER CHER2 CHER2K CHERFS CHERK
        CHESV CHESV_AA CHESV_AA CHESV_AA2STAGE CHESV_AA2STAGE CHESV_RK CHESV_RK
        CHESV_ROOK CHESV_ROOK CHESVX CHESWAPR CHETD2 CHETF2 CHETF2_RK CHETF2_RK
        CHETF2_ROOK CHETF2_ROOK CHETRD CHETRD_2STAGE CHETRD_2STAGE CHETRD_HB2ST
        CHETRD_HB2ST CHETRD_HE2HB CHETRD_HE2HB CHETRF CHETRF_AA CHETRF_AA
        CHETRF_AA2STAGE CHETRF_AA2STAGE CHETRF_RK CHETRF_RK CHETRF_ROOK CHETRF_ROOK
        CHETRI CHETRI2 CHETRI2X CHETRI_3 CHETRI_3 CHETRI_3X CHETRI_3X CHETRI_ROOK
        CHETRI_ROOK CHETRS CHETRS2 CHETRS_3 CHETRS_3 CHETRS_AA CHETRS_AA
        CHETRS_AA2STAGE CHETRS_AA2STAGE CHETRS_ROOK CHETRS_ROOK CHFRK CHGEQZ
        CHLA_TRANSTYPE CHLA_TRANSTYPE CHPCON CHPEV CHPEVD CHPEVX CHPGST CHPGV
        CHPGVD CHPGVX CHPMV CHPR CHPR2 CHPRFS CHPSV CHPSVX CHPTRD CHPTRF
        CHPTRI CHPTRS CHSEIN CHSEQR CIMATCOPY CLABRD CLACGV CLACN2 CLACON
        CLACP2 CLACPY CLACRM CLACRT CLADIV CLAED0 CLAED7 CLAED8 CLAEIN CLAESY
        CLAEV2 CLAG2Z CLAGGE CLAGHE CLAGS2 CLAGSY CLAGTM CLAHEF CLAHEF_AA
        CLAHEF_AA CLAHEF_RK CLAHEF_RK CLAHEF_ROOK CLAHEF_ROOK CLAHILB CLAHQR CLAHR2
        CLAIC1 CLAKF2 CLALS0 CLALSA CLALSD CLAMSWLQ CLAMTSQR CLANGB CLANGE
        CLANGT CLANHB CLANHE CLANHF CLANHP CLANHS CLANHT CLANSB CLANSP CLANSY
        CLANTB CLANTP CLANTR CLAPLL CLAPMR CLAPMT CLAQGB CLAQGE CLAQHB CLAQHE
        CLAQHP CLAQP2 CLAQP2RK CLAQP3RK CLAQPS CLAQR0 CLAQR1 CLAQR2 CLAQR3
        CLAQR4 CLAQR5 CLAQSB CLAQSP CLAQSY CLAQZ0 CLAQZ1 CLAQZ2 CLAQZ3 CLAR1V
        CLAR2V CLARCM CLARF CLARFB CLARFB_GETT CLARFG CLARFGP CLARFT CLARFX
        CLARFY CLARGE CLARGV CLARND CLARNV CLAROR CLAROT CLARRV CLARTG CLARTV
        CLARZ CLARZB CLARZT CLASCL CLASET CLASR CLASSQ CLASWLQ CLASWP CLASYF
        CLASYF_AA CLASYF_AA CLASYF_RK CLASYF_RK CLASYF_ROOK CLASYF_ROOK CLATBS
        CLATDF CLATM1 CLATM2 CLATM3 CLATM5 CLATM6 CLATME CLATMR CLATMS CLATMT
        CLATPS CLATRD CLATRS CLATRS3 CLATRZ CLATSQR CLAUNHR_COL_GETRFNP
        CLAUNHR_COL_GETRFNP CLAUNHR_COL_GETRFNP2 CLAUNHR_COL_GETRFNP2 CLAUU2 CLAUUM
        COMATCOPY CPBCON CPBEQU CPBRFS CPBSTF CPBSV CPBSVX CPBTF2 CPBTRF
        CPBTRS CPFTRF CPFTRI CPFTRS CPOCON CPOEQU CPOEQUB CPORFS CPOSV CPOSVX
        CPOTF2 CPOTRF CPOTRF2 CPOTRI CPOTRS CPPCON CPPEQU CPPRFS CPPSV CPPSVX
        CPPTRF CPPTRI CPPTRS CPSTF2 CPSTRF CPTCON CPTEQR CPTRFS CPTSV CPTSVX
        CPTTRF CPTTRS CPTTS2 CROT CROTG CRSCL CSBMV CSCAL CSPCON CSPMV CSPR
        CSPR2 CSPRFS CSPSV CSPSVX CSPTRF CSPTRI CSPTRS CSROT CSRSCL CSSCAL
        CSTEDC CSTEGR CSTEIN CSTEMR CSTEQR CSWAP CSYCON CSYCON_3 CSYCON_3
        CSYCON_ROOK CSYCON_ROOK CSYCONV CSYCONVF CSYCONVF_ROOK CSYCONVF_ROOK
        CSYEQUB CSYMM CSYMV CSYR CSYR2 CSYR2K CSYRFS CSYRK CSYSV CSYSV_AA
        CSYSV_AA CSYSV_AA2STAGE CSYSV_AA2STAGE CSYSV_RK CSYSV_RK CSYSV_ROOK
        CSYSV_ROOK CSYSVX CSYSWAPR CSYTF2 CSYTF2_RK CSYTF2_RK CSYTF2_ROOK
        CSYTF2_ROOK CSYTRF CSYTRF_AA CSYTRF_AA CSYTRF_AA2STAGE CSYTRF_AA2STAGE
        CSYTRF_RK CSYTRF_RK CSYTRF_ROOK CSYTRF_ROOK CSYTRI CSYTRI2 CSYTRI2X
        CSYTRI_3 CSYTRI_3 CSYTRI_3X CSYTRI_3X CSYTRI_ROOK CSYTRI_ROOK CSYTRS CSYTRS2
        CSYTRS_3 CSYTRS_3 CSYTRS_AA CSYTRS_AA CSYTRS_AA2STAGE CSYTRS_AA2STAGE
        CSYTRS_ROOK CSYTRS_ROOK CTBCON CTBMV CTBRFS CTBSV CTBTRS CTFSM CTFTRI
        CTFTTP CTFTTR CTGEVC CTGEX2 CTGEXC CTGSEN CTGSJA CTGSNA CTGSY2 CTGSYL
        CTPCON CTPLQT CTPLQT2 CTPMLQT CTPMQRT CTPMV CTPQRT CTPQRT2 CTPRFB
        CTPRFS CTPSV CTPTRI CTPTRS CTPTTF CTPTTR CTRCON CTREVC CTREVC3 CTREXC
        CTRMM CTRMV CTRRFS CTRSEN CTRSM CTRSNA CTRSV CTRSYL CTRSYL3 CTRTI2
        CTRTRI CTRTRS CTRTTF CTRTTP CTZRZF CUNBDB CUNBDB1 CUNBDB2 CUNBDB3
        CUNBDB4 CUNBDB5 CUNBDB6 CUNCSD CUNCSD2BY1 CUNG2L CUNG2R CUNGBR CUNGHR
        CUNGL2 CUNGLQ CUNGQL CUNGQR CUNGR2 CUNGRQ CUNGTR CUNGTSQR CUNGTSQR_ROW
        CUNHR_COL CUNHR_COL CUNM22 CUNM2L CUNM2R CUNMBR CUNMHR CUNML2 CUNMLQ
        CUNMQL CUNMQR CUNMR2 CUNMR3 CUNMRQ CUNMRZ CUNMTR CUPGTR CUPMTR DAMAX
        DAMIN DASUM DAXPBY DAXPY DBBCSD DBDSDC DBDSQR DBDSVDX DCABS1 DCOMBSSQ
        DCOPY DDISNA DDOT DGBBRD DGBCON DGBEQU DGBEQUB DGBMV DGBRFS DGBSV
        DGBSVX DGBTF2 DGBTRF DGBTRS DGEADD DGEBAK DGEBAL DGEBD2 DGEBRD DGECON
        DGEDMD DGEDMDQ DGEEQU DGEEQUB DGEES DGEESX DGEEV DGEEVX DGEHD2 DGEHRD
        DGEJSV DGELQ DGELQ2 DGELQF DGELQT DGELQT3 DGELS DGELSD DGELSS DGELST
        DGELSY DGEMLQ DGEMLQT DGEMM DGEMQR DGEMQRT DGEMV DGEQL2 DGEQLF DGEQP3
        DGEQP3RK DGEQR DGEQR2 DGEQR2P DGEQRF DGEQRFP DGEQRT DGEQRT2 DGEQRT3
        DGER DGERFS DGERQ2 DGERQF DGESC2 DGESDD DGESV DGESVD DGESVDQ DGESVDX
        DGESVJ DGESVX DGETC2 DGETF2 DGETRF DGETRF2 DGETRI DGETRS DGETSLS
        DGETSQRHRT DGGBAK DGGBAL DGGES DGGES3 DGGESX DGGEV DGGEV3 DGGEVX
        DGGGLM DGGHD3 DGGHRD DGGLSE DGGQRF DGGRQF DGGSVD3 DGGSVP3 DGSVJ0
        DGSVJ1 DGTCON DGTRFS DGTSV DGTSVX DGTTRF DGTTRS DGTTS2 DHGEQZ DHSEIN
        DHSEQR DIMATCOPY DISNAN DLABAD DLABRD DLACN2 DLACON DLACPY DLADIV
        DLADIV1 DLADIV2 DLAE2 DLAEBZ DLAED0 DLAED1 DLAED2 DLAED3 DLAED4 DLAED5
        DLAED6 DLAED7 DLAED8 DLAED9 DLAEDA DLAEIN DLAEV2 DLAEXC DLAG2 DLAG2S
        DLAGGE DLAGS2 DLAGSY DLAGTF DLAGTM DLAGTS DLAGV2 DLAHILB DLAHQR DLAHR2
        DLAIC1 DLAISNAN DLAKF2 DLALN2 DLALS0 DLALSA DLALSD DLAMC3 DLAMCH
        DLAMRG DLAMSWLQ DLAMTSQR DLANEG DLANGB DLANGE DLANGT DLANHS DLANSB
        DLANSF DLANSP DLANST DLANSY DLANTB DLANTP DLANTR DLANV2
        DLAORHR_COL_GETRFNP DLAORHR_COL_GETRFNP DLAORHR_COL_GETRFNP2
        DLAORHR_COL_GETRFNP2 DLAPLL DLAPMR DLAPMT DLAPY2 DLAPY3 DLAQGB DLAQGE
        DLAQP2 DLAQP2RK DLAQP3RK DLAQPS DLAQR0 DLAQR1 DLAQR2 DLAQR3 DLAQR4
        DLAQR5 DLAQSB DLAQSP DLAQSY DLAQTR DLAQZ0 DLAQZ1 DLAQZ2 DLAQZ3 DLAQZ4
        DLAR1V DLAR2V DLARAN DLARF DLARFB DLARFB_GETT DLARFG DLARFGP DLARFT
        DLARFX DLARFY DLARGE DLARGV DLARMM DLARND DLARNV DLAROR DLAROT DLARRA
        DLARRB DLARRC DLARRD DLARRE DLARRF DLARRJ DLARRK DLARRR DLARRV DLARTG
        DLARTGP DLARTGS DLARTV DLARUV DLARZ DLARZB DLARZT DLAS2 DLASCL DLASD0
        DLASD1 DLASD2 DLASD3 DLASD4 DLASD5 DLASD6 DLASD7 DLASD8 DLASDA DLASDQ
        DLASDT DLASET DLASQ1 DLASQ2 DLASQ3 DLASQ4 DLASQ5 DLASQ6 DLASR DLASRT
        DLASSQ DLASV2 DLASWLQ DLASWP DLASY2 DLASYF DLASYF_AA DLASYF_AA DLASYF_RK
        DLASYF_RK DLASYF_ROOK DLASYF_ROOK DLAT2S DLATBS DLATDF DLATM1 DLATM2
        DLATM3 DLATM5 DLATM6 DLATM7 DLATME DLATMR DLATMS DLATMT DLATPS DLATRD
        DLATRS DLATRS3 DLATRZ DLATSQR DLAUU2 DLAUUM DMAX DMIN DNRM2 DOMATCOPY
        DOPGTR DOPMTR DORBDB DORBDB1 DORBDB2 DORBDB3 DORBDB4 DORBDB5 DORBDB6
        DORCSD DORCSD2BY1 DORG2L DORG2R DORGBR DORGHR DORGL2 DORGLQ DORGQL
        DORGQR DORGR2 DORGRQ DORGTR DORGTSQR DORGTSQR_ROW DORHR_COL DORHR_COL
        DORM22 DORM2L DORM2R DORMBR DORMHR DORML2 DORMLQ DORMQL DORMQR DORMR2
        DORMR3 DORMRQ DORMRZ DORMTR DPBCON DPBEQU DPBRFS DPBSTF DPBSV DPBSVX
        DPBTF2 DPBTRF DPBTRS DPFTRF DPFTRI DPFTRS DPOCON DPOEQU DPOEQUB DPORFS
        DPOSV DPOSVX DPOTF2 DPOTRF DPOTRF2 DPOTRI DPOTRS DPPCON DPPEQU DPPRFS
        DPPSV DPPSVX DPPTRF DPPTRI DPPTRS DPSTF2 DPSTRF DPTCON DPTEQR DPTRFS
        DPTSV DPTSVX DPTTRF DPTTRS DPTTS2 DROT DROTG DROTM DROTMG
        DROUNDUP_LWORK DRSCL DSB2ST_KERNELS DSB2ST_KERNELS DSBEV DSBEV_2STAGE
        DSBEV_2STAGE DSBEVD DSBEVD_2STAGE DSBEVD_2STAGE DSBEVX DSBEVX_2STAGE
        DSBEVX_2STAGE DSBGST DSBGV DSBGVD DSBGVX DSBMV DSBTRD DSCAL DSDOT
        DSECND DSFRK DSGESV DSPCON DSPEV DSPEVD DSPEVX DSPGST DSPGV DSPGVD
        DSPGVX DSPMV DSPOSV DSPR DSPR2 DSPRFS DSPSV DSPSVX DSPTRD DSPTRF
        DSPTRI DSPTRS DSTEBZ DSTEDC DSTEGR DSTEIN DSTEMR DSTEQR DSTERF DSTEV
        DSTEVD DSTEVR DSTEVX DSUM DSWAP DSYCON DSYCON_3 DSYCON_3 DSYCON_ROOK
        DSYCON_ROOK DSYCONV DSYCONVF DSYCONVF_ROOK DSYCONVF_ROOK DSYEQUB DSYEV
        DSYEV_2STAGE DSYEV_2STAGE DSYEVD DSYEVD_2STAGE DSYEVD_2STAGE DSYEVR
        DSYEVR_2STAGE DSYEVR_2STAGE DSYEVX DSYEVX_2STAGE DSYEVX_2STAGE DSYGS2
        DSYGST DSYGV DSYGV_2STAGE DSYGV_2STAGE DSYGVD DSYGVX DSYMM DSYMV DSYR
        DSYR2 DSYR2K DSYRFS DSYRK DSYSV DSYSV_AA DSYSV_AA DSYSV_AA2STAGE
        DSYSV_AA2STAGE DSYSV_RK DSYSV_RK DSYSV_ROOK DSYSV_ROOK DSYSVX DSYSWAPR
        DSYTD2 DSYTF2 DSYTF2_RK DSYTF2_RK DSYTF2_ROOK DSYTF2_ROOK DSYTRD
        DSYTRD_2STAGE DSYTRD_2STAGE DSYTRD_SB2ST DSYTRD_SB2ST DSYTRD_SY2SB
        DSYTRD_SY2SB DSYTRF DSYTRF_AA DSYTRF_AA DSYTRF_AA2STAGE DSYTRF_AA2STAGE
        DSYTRF_RK DSYTRF_RK DSYTRF_ROOK DSYTRF_ROOK DSYTRI DSYTRI2 DSYTRI2X
        DSYTRI_3 DSYTRI_3 DSYTRI_3X DSYTRI_3X DSYTRI_ROOK DSYTRI_ROOK DSYTRS DSYTRS2
        DSYTRS_3 DSYTRS_3 DSYTRS_AA DSYTRS_AA DSYTRS_AA2STAGE DSYTRS_AA2STAGE
        DSYTRS_ROOK DSYTRS_ROOK DTBCON DTBMV DTBRFS DTBSV DTBTRS DTFSM DTFTRI
        DTFTTP DTFTTR DTGEVC DTGEX2 DTGEXC DTGSEN DTGSJA DTGSNA DTGSY2 DTGSYL
        DTPCON DTPLQT DTPLQT2 DTPMLQT DTPMQRT DTPMV DTPQRT DTPQRT2 DTPRFB
        DTPRFS DTPSV DTPTRI DTPTRS DTPTTF DTPTTR DTRCON DTREVC DTREVC3 DTREXC
        DTRMM DTRMV DTRRFS DTRSEN DTRSM DTRSNA DTRSV DTRSYL DTRSYL3 DTRTI2
        DTRTRI DTRTRS DTRTTF DTRTTP DTZRZF DZAMAX DZAMIN DZASUM DZNRM2 DZSUM
        DZSUM1 FINI GOTOSETNUMTHREADS ICAMAX ICAMIN ICMAX1 IDAMAX IDAMIN IDMAX
        IDMIN IEEECK ILACLC ILACLR ILADIAG ILADLC ILADLR ILAENV ILAENV2STAGE
        ILAPREC ILASLC ILASLR ILATRANS ILAUPLO ILAVER ILAZLC ILAZLR INIT
        IPARAM2STAGE IPARMQ ISAMAX ISAMIN ISMAX ISMIN IZAMAX IZAMIN IZMAX1
        LSAME LSAMEN SAMAX SAMIN SASUM SAXPBY SAXPY SBBCSD SBDSDC SBDSQR
        SBDSVDX SCABS1 SCAMAX SCAMIN SCASUM SCNRM2 SCOMBSSQ SCOPY SCSUM SCSUM1
        SDISNA SDOT SDSDOT SECOND SGBBRD SGBCON SGBEQU SGBEQUB SGBMV SGBRFS
        SGBSV SGBSVX SGBTF2 SGBTRF SGBTRS SGEADD SGEBAK SGEBAL SGEBD2 SGEBRD
        SGECON SGEDMD SGEDMDQ SGEEQU SGEEQUB SGEES SGEESX SGEEV SGEEVX SGEHD2
        SGEHRD SGEJSV SGELQ SGELQ2 SGELQF SGELQT SGELQT3 SGELS SGELSD SGELSS
        SGELST SGELSY SGEMLQ SGEMLQT SGEMM SGEMQR SGEMQRT SGEMV SGEQL2 SGEQLF
        SGEQP3 SGEQP3RK SGEQR SGEQR2 SGEQR2P SGEQRF SGEQRFP SGEQRT SGEQRT2
        SGEQRT3 SGER SGERFS SGERQ2 SGERQF SGESC2 SGESDD SGESV SGESVD SGESVDQ
        SGESVDX SGESVJ SGESVX SGETC2 SGETF2 SGETRF SGETRF2 SGETRI SGETRS
        SGETSLS SGETSQRHRT SGGBAK SGGBAL SGGES SGGES3 SGGESX SGGEV SGGEV3
        SGGEVX SGGGLM SGGHD3 SGGHRD SGGLSE SGGQRF SGGRQF SGGSVD3 SGGSVP3
        SGSVJ0 SGSVJ1 SGTCON SGTRFS SGTSV SGTSVX SGTTRF SGTTRS SGTTS2 SHGEQZ
        SHSEIN SHSEQR SIMATCOPY SISNAN SLABAD SLABRD SLACN2 SLACON SLACPY
        SLADIV SLADIV1 SLADIV2 SLAE2 SLAEBZ SLAED0 SLAED1 SLAED2 SLAED3 SLAED4
        SLAED5 SLAED6 SLAED7 SLAED8 SLAED9 SLAEDA SLAEIN SLAEV2 SLAEXC SLAG2
        SLAG2D SLAGGE SLAGS2 SLAGSY SLAGTF SLAGTM SLAGTS SLAGV2 SLAHILB SLAHQR
        SLAHR2 SLAIC1 SLAISNAN SLAKF2 SLALN2 SLALS0 SLALSA SLALSD SLAMC3
        SLAMCH SLAMRG SLAMSWLQ SLAMTSQR SLANEG SLANGB SLANGE SLANGT SLANHS
        SLANSB SLANSF SLANSP SLANST SLANSY SLANTB SLANTP SLANTR SLANV2
        SLAORHR_COL_GETRFNP SLAORHR_COL_GETRFNP SLAORHR_COL_GETRFNP2
        SLAORHR_COL_GETRFNP2 SLAPLL SLAPMR SLAPMT SLAPY2 SLAPY3 SLAQGB SLAQGE
        SLAQP2 SLAQP2RK SLAQP3RK SLAQPS SLAQR0 SLAQR1 SLAQR2 SLAQR3 SLAQR4
        SLAQR5 SLAQSB SLAQSP SLAQSY SLAQTR SLAQZ0 SLAQZ1 SLAQZ2 SLAQZ3 SLAQZ4
        SLAR1V SLAR2V SLARAN SLARF SLARFB SLARFB_GETT SLARFG SLARFGP SLARFT
        SLARFX SLARFY SLARGE SLARGV SLARMM SLARND SLARNV SLAROR SLAROT SLARRA
        SLARRB SLARRC SLARRD SLARRE SLARRF SLARRJ SLARRK SLARRR SLARRV SLARTG
        SLARTGP SLARTGS SLARTV SLARUV SLARZ SLARZB SLARZT SLAS2 SLASCL SLASD0
        SLASD1 SLASD2 SLASD3 SLASD4 SLASD5 SLASD6 SLASD7 SLASD8 SLASDA SLASDQ
        SLASDT SLASET SLASQ1 SLASQ2 SLASQ3 SLASQ4 SLASQ5 SLASQ6 SLASR SLASRT
        SLASSQ SLASV2 SLASWLQ SLASWP SLASY2 SLASYF SLASYF_AA SLASYF_AA SLASYF_RK
        SLASYF_RK SLASYF_ROOK SLASYF_ROOK SLATBS SLATDF SLATM1 SLATM2 SLATM3
        SLATM5 SLATM6 SLATM7 SLATME SLATMR SLATMS SLATMT SLATPS SLATRD SLATRS
        SLATRS3 SLATRZ SLATSQR SLAUU2 SLAUUM SMAX SMIN SNRM2 SOMATCOPY SOPGTR
        SOPMTR SORBDB SORBDB1 SORBDB2 SORBDB3 SORBDB4 SORBDB5 SORBDB6 SORCSD
        SORCSD2BY1 SORG2L SORG2R SORGBR SORGHR SORGL2 SORGLQ SORGQL SORGQR
        SORGR2 SORGRQ SORGTR SORGTSQR SORGTSQR_ROW SORHR_COL SORHR_COL SORM22
        SORM2L SORM2R SORMBR SORMHR SORML2 SORMLQ SORMQL SORMQR SORMR2 SORMR3
        SORMRQ SORMRZ SORMTR SPBCON SPBEQU SPBRFS SPBSTF SPBSV SPBSVX SPBTF2
        SPBTRF SPBTRS SPFTRF SPFTRI SPFTRS SPOCON SPOEQU SPOEQUB SPORFS SPOSV
        SPOSVX SPOTF2 SPOTRF SPOTRF2 SPOTRI SPOTRS SPPCON SPPEQU SPPRFS SPPSV
        SPPSVX SPPTRF SPPTRI SPPTRS SPSTF2 SPSTRF SPTCON SPTEQR SPTRFS SPTSV
        SPTSVX SPTTRF SPTTRS SPTTS2 SROT SROTG SROTM SROTMG SROUNDUP_LWORK
        SRSCL SSB2ST_KERNELS SSB2ST_KERNELS SSBEV SSBEV_2STAGE SSBEV_2STAGE SSBEVD
        SSBEVD_2STAGE SSBEVD_2STAGE SSBEVX SSBEVX_2STAGE SSBEVX_2STAGE SSBGST
        SSBGV SSBGVD SSBGVX SSBMV SSBTRD SSCAL SSFRK SSPCON SSPEV SSPEVD
        SSPEVX SSPGST SSPGV SSPGVD SSPGVX SSPMV SSPR SSPR2 SSPRFS SSPSV SSPSVX
        SSPTRD SSPTRF SSPTRI SSPTRS SSTEBZ SSTEDC SSTEGR SSTEIN SSTEMR SSTEQR
        SSTERF SSTEV SSTEVD SSTEVR SSTEVX SSUM SSWAP SSYCON SSYCON_3 SSYCON_3
        SSYCON_ROOK SSYCON_ROOK SSYCONV SSYCONVF SSYCONVF_ROOK SSYCONVF_ROOK
        SSYEQUB SSYEV SSYEV_2STAGE SSYEV_2STAGE SSYEVD SSYEVD_2STAGE SSYEVD_2STAGE
        SSYEVR SSYEVR_2STAGE SSYEVR_2STAGE SSYEVX SSYEVX_2STAGE SSYEVX_2STAGE
        SSYGS2 SSYGST SSYGV SSYGV_2STAGE SSYGV_2STAGE SSYGVD SSYGVX SSYMM SSYMV
        SSYR SSYR2 SSYR2K SSYRFS SSYRK SSYSV SSYSV_AA SSYSV_AA SSYSV_AA2STAGE
        SSYSV_AA2STAGE SSYSV_RK SSYSV_RK SSYSV_ROOK SSYSV_ROOK SSYSVX SSYSWAPR
        SSYTD2 SSYTF2 SSYTF2_RK SSYTF2_RK SSYTF2_ROOK SSYTF2_ROOK SSYTRD
        SSYTRD_2STAGE SSYTRD_2STAGE SSYTRD_SB2ST SSYTRD_SB2ST SSYTRD_SY2SB
        SSYTRD_SY2SB SSYTRF SSYTRF_AA SSYTRF_AA SSYTRF_AA2STAGE SSYTRF_AA2STAGE
        SSYTRF_RK SSYTRF_RK SSYTRF_ROOK SSYTRF_ROOK SSYTRI SSYTRI2 SSYTRI2X
        SSYTRI_3 SSYTRI_3 SSYTRI_3X SSYTRI_3X SSYTRI_ROOK SSYTRI_ROOK SSYTRS SSYTRS2
        SSYTRS_3 SSYTRS_3 SSYTRS_AA SSYTRS_AA SSYTRS_AA2STAGE SSYTRS_AA2STAGE
        SSYTRS_ROOK SSYTRS_ROOK STBCON STBMV STBRFS STBSV STBTRS STFSM STFTRI
        STFTTP STFTTR STGEVC STGEX2 STGEXC STGSEN STGSJA STGSNA STGSY2 STGSYL
        STPCON STPLQT STPLQT2 STPMLQT STPMQRT STPMV STPQRT STPQRT2 STPRFB
        STPRFS STPSV STPTRI STPTRS STPTTF STPTTR STRCON STREVC STREVC3 STREXC
        STRMM STRMV STRRFS STRSEN STRSM STRSNA STRSV STRSYL STRSYL3 STRTI2
        STRTRI STRTRS STRTTF STRTTP STZRZF XERBLA XERBLA_ARRAY XERBLA_ARRAY
        ZAXPBY ZAXPY ZBBCSD ZBDSQR ZCGESV ZCOPY ZCPOSV ZDOTC ZDOTU ZDROT
        ZDRSCL ZDSCAL ZGBBRD ZGBCON ZGBEQU ZGBEQUB ZGBMV ZGBRFS ZGBSV ZGBSVX
        ZGBTF2 ZGBTRF ZGBTRS ZGEADD ZGEBAK ZGEBAL ZGEBD2 ZGEBRD ZGECON ZGEDMD
        ZGEDMDQ ZGEEQU ZGEEQUB ZGEES ZGEESX ZGEEV ZGEEVX ZGEHD2 ZGEHRD ZGEJSV
        ZGELQ ZGELQ2 ZGELQF ZGELQT ZGELQT3 ZGELS ZGELSD ZGELSS ZGELST ZGELSY
        ZGEMLQ ZGEMLQT ZGEMM ZGEMM3M ZGEMQR ZGEMQRT ZGEMV ZGEQL2 ZGEQLF ZGEQP3
        ZGEQP3RK ZGEQR ZGEQR2 ZGEQR2P ZGEQRF ZGEQRFP ZGEQRT ZGEQRT2 ZGEQRT3
        ZGERC ZGERFS ZGERQ2 ZGERQF ZGERU ZGESC2 ZGESDD ZGESV ZGESVD ZGESVDQ
        ZGESVDX ZGESVJ ZGESVX ZGETC2 ZGETF2 ZGETRF ZGETRF2 ZGETRI ZGETRS
        ZGETSLS ZGETSQRHRT ZGGBAK ZGGBAL ZGGES ZGGES3 ZGGESX ZGGEV ZGGEV3
        ZGGEVX ZGGGLM ZGGHD3 ZGGHRD ZGGLSE ZGGQRF ZGGRQF ZGGSVD3 ZGGSVP3
        ZGSVJ0 ZGSVJ1 ZGTCON ZGTRFS ZGTSV ZGTSVX ZGTTRF ZGTTRS ZGTTS2
        ZHB2ST_KERNELS ZHB2ST_KERNELS ZHBEV ZHBEV_2STAGE ZHBEV_2STAGE ZHBEVD
        ZHBEVD_2STAGE ZHBEVD_2STAGE ZHBEVX ZHBEVX_2STAGE ZHBEVX_2STAGE ZHBGST
        ZHBGV ZHBGVD ZHBGVX ZHBMV ZHBTRD ZHECON ZHECON_3 ZHECON_3 ZHECON_ROOK
        ZHECON_ROOK ZHEEQUB ZHEEV ZHEEV_2STAGE ZHEEV_2STAGE ZHEEVD ZHEEVD_2STAGE
        ZHEEVD_2STAGE ZHEEVR ZHEEVR_2STAGE ZHEEVR_2STAGE ZHEEVX ZHEEVX_2STAGE
        ZHEEVX_2STAGE ZHEGS2 ZHEGST ZHEGV ZHEGV_2STAGE ZHEGV_2STAGE ZHEGVD ZHEGVX
        ZHEMM ZHEMV ZHER ZHER2 ZHER2K ZHERFS ZHERK ZHESV ZHESV_AA ZHESV_AA
        ZHESV_AA2STAGE ZHESV_AA2STAGE ZHESV_RK ZHESV_RK ZHESV_ROOK ZHESV_ROOK ZHESVX
        ZHESWAPR ZHETD2 ZHETF2 ZHETF2_RK ZHETF2_RK ZHETF2_ROOK ZHETF2_ROOK ZHETRD
        ZHETRD_2STAGE ZHETRD_2STAGE ZHETRD_HB2ST ZHETRD_HB2ST ZHETRD_HE2HB
        ZHETRD_HE2HB ZHETRF ZHETRF_AA ZHETRF_AA ZHETRF_AA2STAGE ZHETRF_AA2STAGE
        ZHETRF_RK ZHETRF_RK ZHETRF_ROOK ZHETRF_ROOK ZHETRI ZHETRI2 ZHETRI2X
        ZHETRI_3 ZHETRI_3 ZHETRI_3X ZHETRI_3X ZHETRI_ROOK ZHETRI_ROOK ZHETRS ZHETRS2
        ZHETRS_3 ZHETRS_3 ZHETRS_AA ZHETRS_AA ZHETRS_AA2STAGE ZHETRS_AA2STAGE
        ZHETRS_ROOK ZHETRS_ROOK ZHFRK ZHGEQZ ZHPCON ZHPEV ZHPEVD ZHPEVX ZHPGST
        ZHPGV ZHPGVD ZHPGVX ZHPMV ZHPR ZHPR2 ZHPRFS ZHPSV ZHPSVX ZHPTRD ZHPTRF
        ZHPTRI ZHPTRS ZHSEIN ZHSEQR ZIMATCOPY ZLABRD ZLACGV ZLACN2 ZLACON
        ZLACP2 ZLACPY ZLACRM ZLACRT ZLADIV ZLAED0 ZLAED7 ZLAED8 ZLAEIN ZLAESY
        ZLAEV2 ZLAG2C ZLAGGE ZLAGHE ZLAGS2 ZLAGSY ZLAGTM ZLAHEF ZLAHEF_AA
        ZLAHEF_AA ZLAHEF_RK ZLAHEF_RK ZLAHEF_ROOK ZLAHEF_ROOK ZLAHILB ZLAHQR ZLAHR2
        ZLAIC1 ZLAKF2 ZLALS0 ZLALSA ZLALSD ZLAMSWLQ ZLAMTSQR ZLANGB ZLANGE
        ZLANGT ZLANHB ZLANHE ZLANHF ZLANHP ZLANHS ZLANHT ZLANSB ZLANSP ZLANSY
        ZLANTB ZLANTP ZLANTR ZLAPLL ZLAPMR ZLAPMT ZLAQGB ZLAQGE ZLAQHB ZLAQHE
        ZLAQHP ZLAQP2 ZLAQP2RK ZLAQP3RK ZLAQPS ZLAQR0 ZLAQR1 ZLAQR2 ZLAQR3
        ZLAQR4 ZLAQR5 ZLAQSB ZLAQSP ZLAQSY ZLAQZ0 ZLAQZ1 ZLAQZ2 ZLAQZ3 ZLAR1V
        ZLAR2V ZLARCM ZLARF ZLARFB ZLARFB_GETT ZLARFG ZLARFGP ZLARFT ZLARFX
        ZLARFY ZLARGE ZLARGV ZLARND ZLARNV ZLAROR ZLAROT ZLARRV ZLARTG ZLARTV
        ZLARZ ZLARZB ZLARZT ZLASCL ZLASET ZLASR ZLASSQ ZLASWLQ ZLASWP ZLASYF
        ZLASYF_AA ZLASYF_AA ZLASYF_RK ZLASYF_RK ZLASYF_ROOK ZLASYF_ROOK ZLAT2C
        ZLATBS ZLATDF ZLATM1 ZLATM2 ZLATM3 ZLATM5 ZLATM6 ZLATME ZLATMR ZLATMS
        ZLATMT ZLATPS ZLATRD ZLATRS ZLATRS3 ZLATRZ ZLATSQR ZLAUNHR_COL_GETRFNP
        ZLAUNHR_COL_GETRFNP ZLAUNHR_COL_GETRFNP2 ZLAUNHR_COL_GETRFNP2 ZLAUU2 ZLAUUM
        ZOMATCOPY ZPBCON ZPBEQU ZPBRFS ZPBSTF ZPBSV ZPBSVX ZPBTF2 ZPBTRF
        ZPBTRS ZPFTRF ZPFTRI ZPFTRS ZPOCON ZPOEQU ZPOEQUB ZPORFS ZPOSV ZPOSVX
        ZPOTF2 ZPOTRF ZPOTRF2 ZPOTRI ZPOTRS ZPPCON ZPPEQU ZPPRFS ZPPSV ZPPSVX
        ZPPTRF ZPPTRI ZPPTRS ZPSTF2 ZPSTRF ZPTCON ZPTEQR ZPTRFS ZPTSV ZPTSVX
        ZPTTRF ZPTTRS ZPTTS2 ZROT ZROTG ZRSCL ZSBMV ZSCAL ZSPCON ZSPMV ZSPR
        ZSPR2 ZSPRFS ZSPSV ZSPSVX ZSPTRF ZSPTRI ZSPTRS ZSTEDC ZSTEGR ZSTEIN
        ZSTEMR ZSTEQR ZSWAP ZSYCON ZSYCON_3 ZSYCON_3 ZSYCON_ROOK ZSYCON_ROOK
        ZSYCONV ZSYCONVF ZSYCONVF_ROOK ZSYCONVF_ROOK ZSYEQUB ZSYMM ZSYMV ZSYR
        ZSYR2 ZSYR2K ZSYRFS ZSYRK ZSYSV ZSYSV_AA ZSYSV_AA ZSYSV_AA2STAGE
        ZSYSV_AA2STAGE ZSYSV_RK ZSYSV_RK ZSYSV_ROOK ZSYSV_ROOK ZSYSVX ZSYSWAPR
        ZSYTF2 ZSYTF2_RK ZSYTF2_RK ZSYTF2_ROOK ZSYTF2_ROOK ZSYTRF ZSYTRF_AA
        ZSYTRF_AA ZSYTRF_AA2STAGE ZSYTRF_AA2STAGE ZSYTRF_RK ZSYTRF_RK ZSYTRF_ROOK
        ZSYTRF_ROOK ZSYTRI ZSYTRI2 ZSYTRI2X ZSYTRI_3 ZSYTRI_3 ZSYTRI_3X ZSYTRI_3X
        ZSYTRI_ROOK ZSYTRI_ROOK ZSYTRS ZSYTRS2 ZSYTRS_3 ZSYTRS_3 ZSYTRS_AA ZSYTRS_AA
        ZSYTRS_AA2STAGE ZSYTRS_AA2STAGE ZSYTRS_ROOK ZSYTRS_ROOK ZTBCON ZTBMV
        ZTBRFS ZTBSV ZTBTRS ZTFSM ZTFTRI ZTFTTP ZTFTTR ZTGEVC ZTGEX2 ZTGEXC
        ZTGSEN ZTGSJA ZTGSNA ZTGSY2 ZTGSYL ZTPCON ZTPLQT ZTPLQT2 ZTPMLQT
        ZTPMQRT ZTPMV ZTPQRT ZTPQRT2 ZTPRFB ZTPRFS ZTPSV ZTPTRI ZTPTRS ZTPTTF
        ZTPTTR ZTRCON ZTREVC ZTREVC3 ZTREXC ZTRMM ZTRMV ZTRRFS ZTRSEN ZTRSM
        ZTRSNA ZTRSV ZTRSYL ZTRSYL3 ZTRTI2 ZTRTRI ZTRTRS ZTRTTF ZTRTTP ZTZRZF
        ZUNBDB ZUNBDB1 ZUNBDB2 ZUNBDB3 ZUNBDB4 ZUNBDB5 ZUNBDB6 ZUNCSD
        ZUNCSD2BY1 ZUNG2L ZUNG2R ZUNGBR ZUNGHR ZUNGL2 ZUNGLQ ZUNGQL ZUNGQR
        ZUNGR2 ZUNGRQ ZUNGTR ZUNGTSQR ZUNGTSQR_ROW ZUNHR_COL ZUNM22
        ZUNM2L ZUNM2R ZUNMBR ZUNMHR ZUNML2 ZUNMLQ ZUNMQL ZUNMQR ZUNMR2 ZUNMR3
        ZUNMRQ ZUNMRZ ZUNMTR ZUPGTR ZUPMTR disnan sisnan
        CHESV_AA_2STAGE CHETRF_AA_2STAGE CHETRS_AA_2STAGE
        CSYSV_AA_2STAGE CSYTRF_AA_2STAGE CSYTRS_AA_2STAGE
        DSYSV_AA_2STAGE DSYTRF_AA_2STAGE DSYTRS_AA_2STAGE
        SSYSV_AA_2STAGE SSYTRF_AA_2STAGE SSYTRS_AA_2STAGE
        ZHESV_AA_2STAGE ZHETRF_AA_2STAGE ZHETRS_AA_2STAGE
        ZSYSV_AA_2STAGE ZSYTRF_AA_2STAGE ZSYTRS_AA_2STAGE
        SLARF1L DLARF1L CLARF1L ZLARF1L
        SLARF1F DLARF1F CLARF1F ZLARF1F
        SGEMMTR DGEMMTR CGEMMTR ZGEMMTR
      )

      for sym in ${syms[@]}; do
         FFLAGS+=("-D${sym}=${sym}_64")
      done

      CMAKE_FLAGS+=(-DCMAKE_Fortran_FLAGS=\"${FFLAGS[*]}\")
    fi

    # TODO: LAPACK has a cmake option `BUILD_INDEX64_EXT_API`.
    # This seems to be doing the same as we're doing manually.
    # We should try using this option instead of our hand-rolled magic.

    mkdir build && cd build
    cmake .. "${CMAKE_FLAGS[@]}" \
       -DCMAKE_INSTALL_PREFIX="$prefix" \
       -DCMAKE_FIND_ROOT_PATH="$prefix" \
       -DCMAKE_TOOLCHAIN_FILE="${CMAKE_TARGET_TOOLCHAIN}" \
       -DCMAKE_BUILD_TYPE=Release \
       -DBUILD_SHARED_LIBS=ON \
       -DBUILD_INDEX64_EXT_API=OFF \
       -DTEST_FORTRAN_COMPILER=OFF \
       -DBLAS_LIBRARIES="-L${libdir} -l${BLAS}"

    if [[ "${LAPACK32}" == "true" && "${bb_full_target}" == aarch64-linux-gnu-libgfortran4-cxx11 ]]; then
        # The compiler segfaults at `SRC/claqhp.f:216:0`
        # Build this file ahead of time with reduced optimization.
        (cd /workspace/srcdir/lapack/build/SRC && /opt/bin/aarch64-linux-gnu-libgfortran4-cxx11/aarch64-linux-gnu-gfortran --sysroot=/opt/aarch64-linux-gnu/aarch64-linux-gnu/sys-root/   -O1 -DNDEBUG -O1 -fPIC -frecursive -cpp -c /workspace/srcdir/lapack/SRC/claqhp.f -o CMakeFiles/lapack_obj.dir/claqhp.f.o)
        (cd /workspace/srcdir/lapack/build/SRC && /opt/bin/aarch64-linux-gnu-libgfortran4-cxx11/aarch64-linux-gnu-gfortran --sysroot=/opt/aarch64-linux-gnu/aarch64-linux-gnu/sys-root/   -O1 -DNDEBUG -O1 -fPIC -frecursive -cpp -c /workspace/srcdir/lapack/SRC/zlaqhp.f -o CMakeFiles/lapack_obj.dir/zlaqhp.f.o)
    fi

    make -j${nproc}
    make install

    if [[ -f "${libdir}/libblas.${dlext}" ]]; then
        echo "Error: libblas.${dlext} has been built, linking to libblastrampoline did not work"
        exit 1
    fi

    # Rename liblapack.${dlext} into liblapack32.${dlext}
    if [[ "${LAPACK32}" == "true" ]]; then
        mv -v ${libdir}/liblapack.${dlext} ${libdir}/liblapack32.${dlext}
        # If there were links that are now broken, fix 'em up
        for l in $(find ${prefix}/lib -xtype l); do
          if [[ $(basename $(readlink ${l})) == liblapack ]]; then
            ln -vsf liblapack32.${dlext} ${l}
          fi
        done
        PATCHELF_FLAGS=()
        # ppc64le and aarch64 have 64 kB page sizes, don't muck up the ELF section load alignment
        if [[ ${target} == aarch64-* || ${target} == powerpc64le-* ]]; then
          PATCHELF_FLAGS+=(--page-size 65536)
        fi
        if [[ ${target} == *linux* ]] || [[ ${target} == *freebsd* ]]; then
          patchelf ${PATCHELF_FLAGS[@]} --set-soname liblapack32.${dlext} ${libdir}/liblapack32.${dlext}
        elif [[ ${target} == *apple* ]]; then
          install_name_tool -id liblapack32.${dlext} ${libdir}/liblapack32.${dlext}
        fi
    fi
    """
end

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = expand_gfortran_versions(supported_platforms())

# Dependencies that must be installed before this package can be built
dependencies = [
    Dependency(PackageSpec(name="CompilerSupportLibraries_jll", uuid="e66e0078-7015-5450-92f7-15fbd957f2ae")),
    Dependency(PackageSpec(name="libblastrampoline_jll", uuid="8e850b90-86db-534c-a0d3-1478176c7d93"), compat="5.11.2"),
]
