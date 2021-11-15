﻿// Set Template and Program code. Scenario should be open and CurrentSource
// should point to the target scenario form (in designer mode)
// Parameters:
// RegulatoryReports.Load.Params

form = CurrentSource;

// Unload spreadsheet and script to local storage
mxlFile = GetTempFileName ( "mxl" );
bslFile = GetTempFileName ( "bsl" );
scenario = Test.FindScenario ( _.Path );
data = scenarioData ( scenario.Scenario );
text = new TextWriter ( bslFile );
s = data.Script;
handler = _.BeforeSavingScript;
if ( handler <> undefined ) then
	s = Call ( handler, s );
endif;
text.Write ( s );
text.Close ();

// Set report program export code
Click ( "#LoadExporter" );
With (); // "Enter a file name"
Set ( "#InputFld", bslFile );
Click ( "#OK" );

&AtServer
Function scenarioData ( Scenario )

	data = DF.Values ( Scenario, "Template, Script" );
	result = new Structure ( "Template, Script", data.Template.Get (), data.Script );
	return result;

EndFunction