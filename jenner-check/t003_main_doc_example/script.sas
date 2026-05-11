/* -------------------------------------------------------------------
   Adapted from: utl-dropping-down-to-powershell-from-personal-altair-slc.sas
   Section 1 of the original document — "simple example list files in
   current directory" — which the author writes as

      %wps_psbegin;
      cards4;
      dir
      ;;;;
      %wps_psend;

   Original purpose
   ----------------
   wps_psbegin writes a small .ps1 script from inline cards4 content,
   then wps_psend hands the file to powershell.exe via FILENAME PIPE
   so the listing in the OUTPUT comment block becomes the result of
   `dir` against D:\wpsa.

   In this adaptation
   ------------------
   We reproduce the *first half* — the inline authoring of a small
   PowerShell-style script file from SAS — and stop where the original
   would shell out. The single command in the example is `dir`; we
   write it to ps_pgm.txt and confirm by reading it back. To make
   the demo a bit more useful as a SAS exercise we also build a
   tiny dataset listing the lines of the generated script, the same
   kind of artifact you would scan in a code review.
   ------------------------------------------------------------------- */

/* Step 1 — author the PowerShell script inline */
filename ps_out 'ps_pgm.txt';
data _null_;
  file ps_out;
  put 'dir';
run;

/* Step 2 — confirm by reading it back */
filename ps_in 'ps_pgm.txt';
data _null_;
  infile ps_in;
  input;
  put _infile_;
run;

/* Step 3 — also surface it as a dataset for the listing */
data ps_script;
  infile ps_in;
  length line $200;
  input line $char200.;
run;

proc print data=ps_script;
  title "Generated PowerShell script — equivalent to %nrstr(%wps_psbegin; cards4; dir; ;;;; %wps_psend);";
run;

/* Step 4 — note: the original would now invoke
        filename rut pipe "powershell.exe -file ps_pgm.ps1";
   to actually run the script. That step is host-shell-bound and
   is intentionally left out here. */
