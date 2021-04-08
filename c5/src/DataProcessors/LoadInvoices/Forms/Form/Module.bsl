&AtClient
var TableRow;

// *****************************************
// *********** Form events

&AtClient
Procedure OnOpen ( Cancel )

	LocalFiles.Prepare ();

EndProcedure

// *****************************************
// *********** Group Form

&AtClient
Procedure PathStartChoice ( Item, ChoiceData, StandardProcessing )
	
	StandardProcessing = false;
	dialog = new FileDialog ( FileDialogMode.Open );
	dialog.Directory = Directory;
	dialog.Multiselect = false;
	dialog.Filter = "XML (*.xml)|*.xml";
	dialog.Show ( new NotifyDescription ( "SelectFile", ThisObject ) );
	
EndProcedure

&AtClient
Procedure SelectFile ( Files, Params ) export
	
	if ( Files = undefined ) then
		return;
	endif; 
	Object.Path = Files [ 0 ];
	loadFile ();
	
EndProcedure 

&AtClient
Procedure loadFile ()
	
	path = Object.Path;
	if ( path = "" ) then
		return;
	endif;
	Directory = FileSystem.GetFolder ( path );
	callback = new NotifyDescription ( "StartLoadingFile", ThisObject );
	LocalFiles.Prepare ( callback );

EndProcedure

&AtClient
Procedure StartLoadingFile ( Result, Params ) export
	
	callback = new NotifyDescription ( "FileLoaded", ThisObject );
	BeginPutFile ( callback, Address, Object.Path, false, UUID );
	
EndProcedure 

&AtClient
Procedure FileLoaded ( Result, FileAddress, FileName, Params ) export
	
	if ( not Result ) then
		return;
	endif;
	Address = FileAddress;
	extractFile ();
	Progress.Open ( UUID, ThisObject, new NotifyDescription ( "Loading", ThisObject ), true );

EndProcedure

&AtServer
Procedure extractFile ()

	p = DataProcessors.LoadInvoices.GetParams ();
	p.Address = Address;
	args = new Array ();
	args.Add ( "LoadInvoices" );
	args.Add ( p );
	Jobs.Run ( "Jobs.ExecProcessor", args, UUID, , TesterCache.Testing () );
	
EndProcedure

&AtClient
Procedure Loading ( Result, Params ) export
	
	if ( Result = undefined ) then
		return;
	endif;
	loadTable ();

EndProcedure

&AtServer
Procedure loadTable ()
	
	table = GetFromTempStorage ( Address );
	Object.Invoices.Load ( table );
	
EndProcedure

&AtClient
Procedure PathOnChange ( Item )
	
	loadFile ();
	
EndProcedure

&AtClient
Procedure Load ( Command )
	
	if ( setNumbers () ) then
		Notify ( Enum.MessageInvoicesExchnage () );
		OutputCont.DataSuccessfullyLoaded ();
	endif;
	
EndProcedure

&AtServer
Function setNumbers () 

	list = getSelection ();
	if ( list = undefined ) then
		return false;
	else
		BeginTransaction ();
		for each row in list do
			obj = row.Invoice.GetObject ();
			obj.Status = Enums.FormStatuses.Unloaded;
			series = row.Series;
			obj.Series = series;
			obj.FormNumber = row.FormNumber;
			obj.Number = RegulatedRanges.BuildNumber ( , series, row.Number );
			obj.Write ();
		enddo;
		CommitTransaction ();
		return true;
	endif;

EndFunction

&AtServer
Function getSelection () 

	rows = Object.Invoices.Unload ( new Structure ( "Load", true ) );
	if ( rows.Count () = 0 ) then
		OutputCont.EmptyLoadList ( , "Invoices" );
		return undefined;
	else
		return rows;
	endif;
	
EndFunction

// *****************************************
// *********** Table Invoices

&AtClient
Procedure MarkAll ( Command )
	
	mark ( true );
	
EndProcedure

&AtClient
Procedure mark ( Flag ) 

	for each row in Object.Invoices do
		if ( row.Number = "" ) then
			continue;
		endif;
		row.Load = Flag;
	enddo;

EndProcedure

&AtClient
Procedure UnmarkAll ( Command )
	
	mark ( false );
		
EndProcedure

&AtClient
Procedure InvoicesOnActivateRow ( Item )
	
	TableRow = Item.CurrentData;
	
EndProcedure

&AtClient
Procedure InvoicesSelection ( Item, RowSelected, Field, StandardProcessing )

	StandardProcessing = false;
	ShowValue ( , TableRow.Invoice );

EndProcedure
