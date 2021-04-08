Function GetData ( val Account ) export
	
	data = getAccountData ( Account );
	fields = getDataFields ( data [ 0 ] );
	dims = getDims ( data [ 1 ] );
	return new Structure ( "Fields, Dims", fields, dims );
	
EndFunction

Function getAccountData ( Account )
	
	s = "
	|select Accounts.Currency as Currency, Accounts.Quantitative as Quantitative,
	|	count ( Types.ExtDimensionType ) as Level, isnull ( Children.Exists, false ) as Main
	|from ChartOfAccounts.General as Accounts
	|	//
	|	// Types
	|	//
	|	left join ChartOfAccounts.General.ExtDimensionTypes as Types
	|	on Types.Ref = Accounts.Ref
	|	//
	|	// Hierarchy
	|	//
	|	left join ( select top 1 true as Exists from ChartOfAccounts.General where Parent = &Account ) as Children
	|	on true
	|where Accounts.Ref = &Account
	|group by Accounts.Ref, isnull ( Children.Exists, false )
	|;
	|select Types.LineNumber as LineNumber, Types.ExtDimensionType as ExtDimensionType,
	|	Types.ExtDimensionType.ValueType as ValueType, presentation ( Types.ExtDimensionType ) as Presentation
	|from ChartOfAccounts.General.ExtDimensionTypes as Types
	|where Types.Ref = &Account
	|order by Types.LineNumber
	|";
	q = new Query ( s );
	q.SetParameter ( "Account", Account );
	return q.ExecuteBatch ();
	
EndFunction 

Function getDataFields ( Result )
	
	table = Result.Unload ();
	fields = new Structure ( "Currency, Quantitative, Level, Main", false, false, 0, false );
	if ( table.Count () > 0 ) then
		FillPropertyValues ( fields, table [ 0 ] );
	endif; 	
	return fields;
	
EndFunction 

Function getDims ( Result )
	
	dims = new Array ();
	table = Result.Unload ();
	for each row in table do
		p = new Structure ( "LineNumber, Dim, ValueType, Presentation" );
		p.LineNumber = row.LineNumber;
		p.Dim = row.ExtDimensionType;
		p.ValueType = row.ValueType;
		p.Presentation = row.Presentation;
		dims.Add ( p );
	enddo; 
	return dims;
	
EndFunction 

Function DimsCount ( val Account ) export
	
	s = "
	|select count ( Types.ExtDimensionType ) as Count
	|from ChartOfAccounts.General.ExtDimensionTypes as Types
	|where Types.Ref = &Account
	|";
	q = new Query ( s );
	q.SetParameter ( "Account", Account );
	result = q.Execute ().Unload () [ 0 ].Count;
	return ? ( result = null, 0, result );
	
EndFunction

Function Main ( val Account ) export
	
	s = "
	|select top 1 true
	|from ChartOfAccounts.General
	|where Parent = &Account	
	|";
	q = new Query ( s );
	q.SetParameter ( "Account", Account );
	return q.Execute ().Unload ().Count () = 1;

EndFunction 
