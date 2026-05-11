/* -------------------------------------------------------------------
   Adapted from: wps_psbegin.sas (Roger DeAngelis, github)

   Original purpose
   ----------------
   wps_psbegin opens a fileref to a temporary PowerShell script file
   and starts a DATA _NULL_ block that captures the cards4 input lines
   and writes them to that file. The companion wps_psend then runs the
   PowerShell script via a `filename ... pipe` step.

   In this adaptation
   ------------------
   We keep the *intent* — generate a small script-like text file from
   inline SAS statements — and drop only the host-shell escape. The
   FILENAME / FILE / PUT mechanics are exactly the SAS technique the
   author was exploring; here we exercise that mechanic standalone and
   then read the file back to demonstrate it really was written.
   ------------------------------------------------------------------- */

%macro wps_psbegin_jenner(out=ps_pgm.txt);
  filename ft15f001 "&out";
  data _null_;
    file ft15f001;
    put "Get-ChildItem -Path .";
    put "Write-Output 'hello from a generated script'";
    put "Get-Date";
  run;
%mend wps_psbegin_jenner;

/* Generate the script file */
%wps_psbegin_jenner(out=ps_pgm.txt);

/* Verify by reading it back */
filename ps_in "ps_pgm.txt";
data _null_;
  infile ps_in;
  input;
  put _infile_;
run;

/* Also load it as a dataset so listing output shows the contents */
data generated_script;
  infile ps_in;
  length line $200;
  input line $char200.;
run;

proc print data=generated_script;
  title "Generated PowerShell script content";
run;
