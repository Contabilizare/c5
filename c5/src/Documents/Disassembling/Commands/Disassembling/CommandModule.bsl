
&AtClient
Procedure CommandProcessing ( List, CommandExecuteParameters )
	
	p = Print.GetParams ();
	p.Objects = List;
	name = "Disassembling";
	p.Key = name;
	p.Name = name;
	p.Languages = "en, ru";
	Print.Print ( p );
	
EndProcedure
