
&AtClient
Procedure CommandProcessing ( List, CommandExecuteParameters )
	
	p = Print.GetParams ();
	p.Manager = "DataProcessors.OV8";
	p.Objects = List;
	name = "LVIWriteOff";
	p.Key = name;
	p.Name = name;
	Print.Print ( p );
	
EndProcedure


