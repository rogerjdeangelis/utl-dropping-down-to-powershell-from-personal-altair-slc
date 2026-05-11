/* -------------------------------------------------------------------
   Adapted from: wps_submit_ps64x.sas  (Roger DeAngelis, github)
   Original macro: utl_submit_ps64x

   Original purpose
   ----------------
   utl_submit_ps64x accepts a single-quoted, semicolon-separated string
   of PowerShell statements. The macro splits the string on `;`, writes
   each statement on its own line of a .ps1 file using a DATA _NULL_
   that drives a SCAN + COUNTC + DO loop, then pipes the file through
   `powershell.exe`.

   In this adaptation
   ------------------
   The string-splitting + file-writing core is pure SAS — that is what
   we exercise here. We feed in the canonical example from the macro's
   own comment header ("Get-Content ... | Measure-Object -Line | clip;")
   and let the SCAN/COUNTC loop split it into tokens, write each token
   to a file, and then we read the file back to confirm. The
   `filename rut pipe ...` step at the end of the original is dropped
   because Jenner sandboxes host-shell escapes.
   ------------------------------------------------------------------- */

%let pgm = %str(Get-Content -Path d:/txt/back.txt | Measure-Object -Line | clip;);

filename ps_out 'ps_pgm.ps1';

data _null_;
  length cmd $1024;
  file ps_out;
  pgm = "&pgm";
  semi = countc(pgm, ';');
  do idx = 1 to semi;
    cmd = cats(scan(pgm, idx, ';'));
    if cmd =: '. ' then cmd = trim(substr(cmd, 2));
    put cmd;
  end;
run;

/* Read the generated file back */
filename ps_in 'ps_pgm.ps1';
data _null_;
  infile ps_in;
  input;
  put _infile_;
run;

/* And surface as a dataset for the PROC PRINT listing */
data ps_lines;
  infile ps_in;
  length line $200;
  input line $char200.;
run;

proc print data=ps_lines;
  title "Tokenized PowerShell statements (input string split on semicolons)";
run;
