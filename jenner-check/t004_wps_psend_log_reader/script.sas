/* -------------------------------------------------------------------
   Adapted from: wps_psend.sas  (Roger DeAngelis, github)

   Original purpose
   ----------------
   wps_psend runs the .ps1 file produced by wps_psbegin via FILENAME
   PIPE, then reads the captured stdout (the `rut` fileref) plus the
   log file c:/temp/ps_pgm.log. The log-reading DATA _NULL_ at the
   bottom of the macro is

      data _null_;
        infile "c:/temp/ps_pgm.log";
        input;
        putlog _infile_;
      run;

   In this adaptation
   ------------------
   We mimic what that fragment is for — picking up a log file from
   disk and echoing it into the SAS log + listing — by first writing
   a small log file ourselves (so the bundle is self-contained) and
   then running the read-and-echo step exactly as the macro does it,
   plus a parallel pass that loads the same log into a dataset for a
   PROC PRINT listing.
   ------------------------------------------------------------------- */

/* Step 1 — fabricate a small log file in place of the one that
   the original would receive from `powershell.exe ... > log` */
filename log_out 'ps_pgm.log';
data _null_;
  file log_out;
  put 'Directory: D:\wpsa';
  put ' ';
  put 'Mode          LastWriteTime   Length Name';
  put '----          -------------   ------ ----';
  put 'd-----  9/17/2025  12:07 PM          python_plots';
  put 'd-----  9/20/2025   2:49 PM          Samples';
  put '-a----  9/19/2025  12:54 PM   107086 .metadata.zip';
run;

/* Step 2 — the log-reading pattern, copied straight from the
   tail of wps_psend */
filename log_in 'ps_pgm.log';
data _null_;
  infile log_in;
  input;
  put _infile_;
  putlog _infile_;
run;

/* Step 3 — same content, but loaded as a dataset so the
   listing reflects what was on disk */
data ps_log;
  infile log_in;
  length line $80;
  input line $char80.;
run;

proc print data=ps_log;
  title "Contents of ps_pgm.log (read with INFILE + INPUT + PUT _INFILE_)";
run;
