    %let pgm=utl-dropping-down-to-powershell-from-personal-altair-slc;

    %stop_submission;

    Dropping down to powershell from personal altair slc

    Too long to post here, see github

    SOAPBOX ON

    I am new to the personal version of the Altair SLC, so all of this may not betrue.
    I expert peer review would be nice?

    CONTENTS
       1 simple example list files in current directory

       2 powershell macros (here and in https://tinyurl.com/y9nfugth)
         wps_psbegin
         wps_psend
         wps_pssubmit_ps64

    github
    https://github.com/rogerjdeangelis/utl-dropping-down-to-powershell-from-personal-altair-slc

    Related
    github
    https://github.com/rogerjdeangelis/utl-calling-r-from-personal-altair-slc-and-integrating-r-with-sql

    github
    https://github.com/rogerjdeangelis/utl-calling-python-from-personal-altair-slc-and-integrating-python-with-sql

    macros
    https://github.com/rogerjdeangelis/utl-macros-used-in-many-of-rogerjdeangelis-repositories

    /*       _                 _                                       _
    / |  ___(_)_ __ ___  _ __ | | ___    _____  ____ _ _ __ ___  _ __ | | ___
    | | / __| | `_ ` _ \| `_ \| |/ _ \  / _ \ \/ / _` | `_ ` _ \| `_ \| |/ _ \
    | | \__ \ | | | | | | |_) | |  __/ |  __/>  < (_| | | | | | | |_) | |  __/
    |_| |___/_|_| |_| |_| .__/|_|\___|  \___/_/\_\__,_|_| |_| |_| .__/|_|\___|
                        |_|                                     |_|
     _ __  _ __ ___   ___ ___  ___ ___
    | `_ \| `__/ _ \ / __/ _ \/ __/ __|
    | |_) | | | (_) | (_|  __/\__ \__ \
    | .__/|_|  \___/ \___\___||___/___/
    |_|
    */

    %wps_psbegin;
    cards4;
    dir
    ;;;;
    %wps_psend;

    OUTPUT

    Directory: D:\wpsa

    Mode          LastWriteTime   Length Name
    ----          -------------   ------ ----
    d-----  9/17/2025  12:07 PM          .altairRemoteSystemsTempFiles
    d-----  9/20/2025   3:04 PM          .metadata
    d-----  9/19/2025  11:28 AM          .metadata - Copy
    d-----  9/17/2025  12:07 PM          python_plots
    d-----  9/20/2025   2:49 PM          Samples
    -a----  9/19/2025  12:54 PM   107086 .metadata.zip


    /*--- the semicolon is needed after the dir ---*/
    %wps_submit_ps64x('
    dir;
    ');

    OUTPUT
    ------
        Directory: C:\slc


    Mode           LastWriteTime      Length Name
    ----           -------------      ------ ----
    -a----  11/25/2025   3:02 PM      186709 0
    -a----   12/1/2025  12:06 PM           0 current.log
    -a----   12/1/2025   9:02 AM      274742 current.log.bak
    -a----   12/1/2025  12:06 PM           0 current.lst
    -a----   12/1/2025  12:06 PM        1381 current.sas
    -a----   12/1/2025  12:01 PM        1380 current.sas.bak
    -a----  11/30/2025   8:05 AM          11 delete.dat
    -a----   11/4/2025   5:06 PM        3628 dos.js
    -a----   11/4/2025   5:07 PM        2348 idonnot.js



    /*___                                     _          _ _
    |___ \   _ __   _____      _____ _ __ ___| |__   ___| | | _ __ ___   __ _  ___ _ __ ___  ___
      __) | | `_ \ / _ \ \ /\ / / _ \ `__/ __| `_ \ / _ \ | || `_ ` _ \ / _` |/ __| `__/ _ \/ __|
     / __/  | |_) | (_) \ V  V /  __/ |  \__ \ | | |  __/ | || | | | | | (_| | (__| | | (_) \__ \
    |_____| | .__/ \___/ \_/\_/ \___|_|  |___/_| |_|\___|_|_||_| |_| |_|\__,_|\___|_|  \___/|___/
            |_|
    */

    /*--- copy to autocall library ---*/
    filename ft15f001 "c:/wpsoto/wps_submit_ps64.sas";
    data _null_;
     file ft15f001;
     input;
     put _infile;
    cards4;
    %macro utl_submit_ps64x(
          pgm
         ,return=  /* name for the macro variable from Powershell */
         )/des="Semi colon separated set of Powershell commands - drop down to Powershell";
      /*
          %let pgm='Get-Content -Path d:/txt/back.txt | Measure-Object -Line | clip;';
      */
      * write the program to a temporary file;
      filename py_pgm "%sysfunc(pathname(work))/py_pgm.ps1" lrecl=32766 recfm=v;
      data _null_;
        length pgm  $32755 cmd $1024;
        file py_pgm ;
        pgm=&pgm;
        semi=countc(pgm,';');
          do idx=1 to semi;
            cmd=cats(scan(pgm,idx,';'));
            if cmd=:'. ' then
               cmd=trim(substr(cmd,2));
             put cmd $char384.;
             putlog cmd $char384.;
          end;
      run;quit;
      %let _loc=%sysfunc(pathname(py_pgm));
      %put &_loc;
      filename rut pipe  "powershell.exe -executionpolicy bypass -file &_loc ";
      data _null_;
        file print;
        infile rut;
        input;
        put _infile_;
        putlog _infile_;
      run;
      filename rut clear;
      filename py_pgm clear;
      * use the clipboard to create macro variable;
      %if "&return" ^= "" %then %do;
        filename clp clipbrd ;
        data _null_;
         length txt $200;
         infile clp;
         input;
         putlog "*******  " _infile_;
         call symputx("&return",_infile_,"G");
        run;quit;
      %end;
    %mend utl_submit_ps64x;
    ;;;;
    run;quit;




    /*--- copy to autocall library c:/wpsoto ---*/
    filename ft15f001 "c:/wpsoto/wps_psbegin.sas";
    data _null_;
     file ft15f001;
     input;
     put _infile;
    cards4;
    %macro wps_psbegin;
    %utlfkil(c:/temp/ps_pgm.ps);
    %utlfkil(c:/temp/ps_pgm.log);
    filename ft15f001 "c:/temp/ps_pgm.ps1";
    data _null_;
     file ft15f001;
     input;
     put _infile_;
    %mend wps_psbegin;
    ;;;;
    run;quit;


    /*--- copy to autocall library c:/wpsoto ---*/
    filename ft15f001 "c:/wpsoto/wps_psend.sas";
    data _null_;
     file ft15f001;
     input;
     put _infile;
    cards4;
    %macro wps_psend(returnvar=N);
    options noxwait noxsync;
    filename rut pipe  "powershell.exe -executionpolicy bypass -file c:/temp/ps_pgm.ps1 >  c:/temp/ps_pgm.log";
    run;quit;
      data _null_;
        file print;
        infile rut recfm=v lrecl=32756;
        input;
        put _infile_;
        putlog _infile_;
      run;
      filename ft15f001 clear;
      * use the clipboard to create macro variable;
      %if %upcase(%substr(&returnVar.,1,1)) ne N %then %do;
        filename clp clipbrd ;
        data _null_;
         length txt $200;
         infile clp;
         input;
         putlog "macro variable &returnVar = " _infile_;
         call symputx("&returnVar.",_infile_,"G");
        run;quit;
      %end;
    data _null_;
      file print;
      infile rut;
      input;
      put _infile_;
      putlog _infile_;
    run;quit;
    data _null_;
      infile "c:/temp/ps_pgm.log";
      input;
      putlog _infile_;
    run;quit;
    filename ft15f001 clear;
    %mend wps_psend;
    ;;;;
    run;quit;

    /*              _
      ___ _ __   __| |
     / _ \ `_ \ / _` |
    |  __/ | | | (_| |
     \___|_| |_|\__,_|

    */

