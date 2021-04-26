﻿// Before running this test make sure 1c-enterprise server had been
// restarted after the latest edt update. Otherwise, ring utility will not
// be found

// Parameters
platform = "8.3.18.1363";
edt = "edt@2021.1.1:x86_64";

// Routine
p = Call("Tester.Execute.Params");
p.Platform = "/opt/1cv8/x86_64/" + platform + "/1cv8";
p.EDT = edt;
p.Application = AppName;
p.Server = "localhost";
p.ServerIBName = AppName;
p.IBName = AppName;
p.IBUser = "root";
p.Restore = "/home/dmitry/testing/" + AppName + "/init.dt";
p.TestEnvironment = "TotalTest.TestEnvironment";
p.Project = AppName;
p.Workspace = "/home/dmitry/" + AppName;
p.GitFolder = "/home/dmitry/git/" + AppName;
p.GitUser = "nullarity";
p.GitPassword = Call ("TotalTest.GitPassword", , "System");
p.GitRepo = "github.com/contabilizare/c5";
p.TestingOnly = _ <> undefined and _ = "TestingOnly";
exceptions = new Array();
exceptions.Add("Documents.Document.ChangeBook");
exceptions.Add("Documents.Document.CopyDocumentWithFiles");
exceptions.Add("Documents.Document.CopyDocumentWithSpreadsheetOnly");
exceptions.Add("Documents.Document.ExportPrintFormToDocument");
exceptions.Add("Documents.Document.PrintFromForm");
exceptions.Add("Documents.Document.PrintFromList");
exceptions.Add("Documents.Document.PublishChangedFiles");
exceptions.Add("Documents.Document.RenameFile");
exceptions.Add("Documents.Document.TheSameSubject");
exceptions.Add("DataProcessors.Update.RegularUpdate");
exceptions.Add("DataProcessors.Update.SkipUpdate");
exceptions.Add("CommonForms.Settings.TestClosingAfterChangingLicense");
p.Exceptions = exceptions;

agents = 25;
batch = 5;

StoreScenarios ();
for i = 1 to agents do
	NewJob ( "tester", "TotalTest.DisconnectClients", , , "tc" + i );
enddo;

Pause (60);

// Restore & update database 
if ( not p.TestingOnly ) then
	Call ( "Tester.Infobase.Deploy", p );
endif;
if ( p.UpdateOnly ) then
	return;
endif;

params = new Structure ();
params.Insert ( "Name", String ( p.Application ) );
params.Insert ( "Folder", p.Folder );
params.Insert ( "Exceptions", p.Exceptions );
list = Call ( "Tester.Scenarios", params );
listSize = list.Count () - 1;
chunk = new Array ();
job = CurrentDelegatedJob.Job;
for i = 0 to batch - 1 do
	k = 0;
	j = i;
	while ( j <= listSize ) do
		if ( k = 0 ) then
			if ( chunk.Count () > 0 ) then
				NewJob ( "Tester", chunk );
			endif;
			chunk.Clear ();
		endif;
		record = ParametersSpace ().JobRecord ();
		record.Scenario = list [ j ];
		record.PinApplication = p.Application;
		record.Disconnect = false;
		chunk.Add ( record );
		k = ? ( k = batch, 0, k + 1 );
		j = j + batch;
	enddo;
	NewJob ( "Tester", chunk, , , , , , job );
	chunk.Clear ();
enddo;
