&AtServer
Procedure SetContractCurrency ( Form ) export
	
	object = Form.Object;
	Form.ContractCurrency = DF.Pick ( object.Contract, "Currency", undefined );
	
EndProcedure 

&AtServer
Procedure SetLocalCurrency ( Form ) export
	
	Form.LocalCurrency = Application.Currency ();
	
EndProcedure 

&AtServer
Procedure SetCurrencyList ( Form ) export

	local = Form.LocalCurrency;
	contract = Form.ContractCurrency;
	list = Form.Items.Currency.ChoiceList;
	list.Clear ();
	list.Add ( local );
	if ( contract <> local
		and not contract.IsEmpty () ) then
		list.Add ( contract );
	endif;
	
EndProcedure

&AtServer
Procedure SetDelivery ( Form, Contract ) export
	
	object = Form.Object;
	days = Contract.Delivery;
	if ( days = 0 ) then
		object.DeliveryDate = undefined;
	else
		object.DeliveryDate = object.Date + days * 86400;
	endif;
	
EndProcedure

&AtServer
Procedure SetRate ( Form ) export
	
	object = Form.Object;
	if ( object.Contract.IsEmpty () ) then
		return;
	endif;
	currencyRate = contractCurrencyRate ( object );
	if ( currencyRate = undefined ) then
		if ( Form.ContractCurrency = Form.LocalCurrency ) then
			currency = object.Currency;
		else
			currency = Form.ContractCurrency;
		endif; 
		currencyRate = CurrenciesSrv.Get ( currency );
	endif;
	object.Rate = currencyRate.Rate;
	object.Factor = currencyRate.Factor;
	
EndProcedure 

&AtServer
Function contractCurrencyRate ( Object )
	
	contract = Object.Contract;
	type = TypeOf ( object.Ref );
	isQuote = type = Type ( "DocumentRef.Quote" );
	isSO = type = Type ( "DocumentRef.SalesOrder" );
	isInvoice = type = Type ( "DocumentRef.Invoice" );
	isPO = type = Type ( "DocumentRef.PurchaseOrder" );
	isVendorInvoice = type = Type ( "DocumentRef.VendorInvoice" );
	isReturn = type = Type ( "DocumentRef.Return" );
	isVendorReturn = type = Type ( "DocumentRef.VendorReturn" );
	if ( isQuote or isReturn ) then
		data = DF.Values ( contract, "CustomerRateType, CustomerRate, CustomerFactor" );
		if ( data.CustomerRateType = Enums.CurrencyRates.Fixed
			and data.CustomerRate <> 0 ) then
			return contractRate ( data.CustomerRate, data.CustomerFactor );
		endif;
	elsif ( isSO or isInvoice ) then
		data = DF.Values ( contract, "CustomerRateType, CustomerRate, CustomerFactor" );
		base = ? ( isSO, object.Quote, object.SalesOrder );
		if ( data.CustomerRateType = Enums.CurrencyRates.Fixed ) then
			if ( not base.IsEmpty () ) then
				return DF.Values ( base, "Rate, Factor" );
			elsif ( data.CustomerRate <> 0 ) then
				return contractRate ( data.CustomerRate, data.CustomerFactor );
			endif;
		endif;
	elsif ( isPO or isVendorReturn ) then
		data = DF.Values ( contract, "VendorRateType, VendorRate, VendorFactor" );
		if ( data.VendorRateType = Enums.CurrencyRates.Fixed
			and data.VendorRate <> 0 ) then
			return contractRate ( data.VendorRate, data.VendorFactor );
		endif;
	elsif ( isVendorInvoice ) then
		data = DF.Values ( contract, "VendorRateType, VendorRate, VendorFactor" );
		base = object.PurchaseOrder;
		if ( data.VendorRateType = Enums.CurrencyRates.Fixed ) then
			if ( not base.IsEmpty () ) then
				return DF.Values ( base, "Rate, Factor" );
			elsif ( data.VendorRate <> 0 ) then
				return contractRate ( data.VendorRate, data.VendorFactor );
			endif;
		endif;
	endif;
	return undefined;
	
EndFunction

&AtServer
Function contractRate ( Rate, Factor )
	
	return new Structure ( "Rate, Factor", Rate, Factor );
	
EndFunction

Procedure CalcTotals ( Source ) export
	
	p = getTotalParams ( Source );
	object = p.Object;
	items = object.Items;
	services = object.Services;
	amount = items.Total ( "Total" ) + services.Total ( "Total" );
	object.VAT = items.Total ( "VAT" ) + services.Total ( "VAT" );
	object.Amount = amount;
	object.Discount = items.Total ( "Discount" ) + services.Total ( "Discount" );
	object.GrossAmount = amount - ? ( object.VATUse = 2, object.VAT, 0 ) + object.Discount;
	if ( not p.CalcContractAmount ) then
		return;
	endif;
	if ( p.ContractCurrency = object.Currency ) then
		object.ContractAmount = amount;
	else
		if ( object.Currency = p.LocalCurrency) then
			object.ContractAmount = amount / object.Rate * object.Factor;
		else
			object.ContractAmount = amount * object.Rate / object.Factor;
		endif; 
	endif; 
	
EndProcedure 

Function getTotalParams ( Source )
	
	params = new Structure ( "Object, CalcContractAmount, LocalCurrency, ContractCurrency" );
	clientForm = TypeOf ( Source ) = Type ( "ClientApplicationForm" );
	object = ? ( clientForm, Source.Object, Source );
	type = TypeOf ( object.Ref );
	if ( type = Type ( "DocumentRef.ExpenseReport" )
		or type = Type ( "CatalogRef.Leads" ) ) then
		params.CalcContractAmount = false;
	else
		params.CalcContractAmount = true;
		if ( clientForm ) then
			params.LocalCurrency = Source.LocalCurrency;
			params.ContractCurrency = Source.ContractCurrency;
		else
			params.LocalCurrency = Application.Currency ();
			params.ContractCurrency = object.ContractCurrency;
		endif;
	endif;
	params.Object = object;
	return params;
	
EndFunction

&AtServer
Procedure SetPayment ( Object ) export
	
	vendor = isPurchase ( Object );
	option = getPaymentOption ( Object, vendor );
	if ( option = undefined ) then
		Object.PaymentOption = undefined;
		Object.PaymentDate = undefined;
	else
		Object.PaymentOption = option.Value;
		Object.PaymentDate = Periods.GetDocumentDate ( Object ) + option.Due * 86400;
	endif; 
	
EndProcedure 

&AtServer
Function isPurchase ( Object )
	
	return TypeOf ( Object.Ref ) = Type ( "DocumentRef.VendorInvoice" );
	
EndFunction 

&AtServer
Function getPaymentOption ( Object, Vendor )
	
	if ( Vendor ) then
		terms = "VendorTerms";
		register = "VendorDebts";
	else
		terms = "CustomerTerms";
		register = "Debts";
	endif; 
	list = getOrders ( Object, Vendor );
	if ( list.Count () = 0 ) then
		s = "
		|select top 1 Payments.Option as Value, Payments.Option.Due as Due
		|from Catalog.Terms.Payments as Payments
		|where Payments.Ref in ( select " + terms + " from Catalog.Contracts where Ref = &Contract )
		|and Payments.Variant = value ( Enum.PaymentVariants.OnDelivery )
		|";
	else
		s = "
		|select distinct Payments.Option as Option
		|into Options
		|from Catalog.Terms.Payments as Payments
		|where Payments.Ref in ( select " + terms + " from Catalog.Contracts where Ref = &Contract )
		|and Payments.Variant = value ( Enum.PaymentVariants.OnDelivery )
		|index by Option
		|;
		|select Payments.PaymentKey as Key, Payments.Date
		|into Keys
		|from InformationRegister.PaymentDetails as Payments
		|where Payments.Option in ( select Option from Options )
		|and Payments.Date = datetime ( 3999, 12, 31 )
		|index by Key
		|;
		|select Payments.Option as Value, Payments.Option.Due as Due
		|from AccumulationRegister." + register + ".Balance ( &Date,
		|	Contract = &Contract
		|	and PaymentKey in ( select Key from Keys )
		|	and Document in ( &Orders ) ) as Balances
		|	//
		|	// Payment Keys
		|	//
		|	join InformationRegister.PaymentDetails as Payments
		|	on Payments.PaymentKey = Balances.PaymentKey
		|	and Payments.Date = datetime ( 3999, 12, 31 )
		|where ( Balances.PaymentBalance - Balances.AmountBalance ) > 0
		|or Balances.OverpaymentBalance > 0
		|order by Balances.Document.Date
		|";
	endif;
	q = new Query ( s );
	q.SetParameter ( "Contract", Object.Contract );
	q.SetParameter ( "Orders", list );
	q.SetParameter ( "Date", Periods.GetBalanceDate ( Object ) );
	SetPrivilegedMode ( true );
	table = q.Execute ().Unload ();
	return ? ( table.Count () = 0, undefined, table [ 0 ] );
	
EndFunction 

&AtServer
Function getOrders ( Object, Vendor )
	
	map = new Map ();
	document = ? ( Vendor, Object.PurchaseOrder, Object.SalesOrder );
	if ( not document.IsEmpty () ) then
		map.Insert ( document );
	endif; 
	tables = new Array ();
	tables.Add ( Object.Items );
	tables.Add ( Object.Services );
	for each table in tables do
		for each row in table do
			document = ? ( Vendor, row.PurchaseOrder, row.SalesOrder );
			if ( not document.IsEmpty () ) then
				map.Insert ( document );
			endif; 
		enddo; 
	enddo; 
	result = new Array ();
	for each item in map do
		result.Add ( item.Key );
	enddo; 
	return result;
	
EndFunction 

&AtServer
Procedure SetDiscounts ( Object ) export
		
	vendor = isPurchase ( Object );
	table = getDiscounts ( Object, vendor );
	Object.Discounts.Load ( table );
	
EndProcedure

&AtServer
Function getDiscounts ( Object, Vendor )
	
	if ( Vendor ) then
		table = "AccumulationRegister.VendorDiscounts";
		document = "PurchaseOrder";
	else
		table = "AccumulationRegister.Discounts";
		document = "SalesOrder";
	endif; 
	s = "
	|select Discounts.Document as " + document + ", sum ( Discounts.Amount ) as Discount
	|from (
	|	select Discounts.Document as Document, Discounts.Amount as Amount
	|	from " + table + " as Discounts
	|	where Discounts.Document in ( &Orders )
	|	and Discounts.Period < &Date
	|	union all
	|	select Discounts.Detail, - Discounts.Amount
	|	from " + table + " as Discounts
	|	where Discounts.Detail in ( &Orders )
	|	and Discounts.Period < &Date
	|	) as Discounts
	|group by Discounts.Document
	|having sum ( Discounts.Amount ) > 0
	|order by Discounts.Document.Date
	|";
	q = new Query ( s );
	q.SetParameter ( "Ref", Object.Ref );
	q.SetParameter ( "Contract", Object.Contract );
	q.SetParameter ( "Date", Periods.GetDocumentDate ( Object ) );
	q.SetParameter ( "Orders", getOrders ( Object, Vendor ) );
	SetPrivilegedMode ( true );
	return q.Execute ().Unload ();
	
EndFunction 

&AtServer
Procedure SetPaymentsApplied ( Form ) export
	
	if ( not documentReady ( Form ) ) then
		Form.PaymentsApplied = 0;
		Form.Benefit = 0;
		return;
	endif;
	object = Form.Object;
	type = TypeOf ( object.Ref );
	if ( object.Posted
		or type = Type ( "DocumentRef.SalesOrder" )
		or type = Type ( "DocumentRef.PurchaseOrder" ) ) then
		data = getDebt ( Object );
		benefit = data.Benefit;
		Form.PaymentsApplied = object.ContractAmount - benefit - data.Debt;
		Form.Benefit = benefit;
	else
		data = getAdvance ( Object );
		Form.PaymentsApplied = Min ( data.Advance, object.ContractAmount );
		Form.Benefit = data.Benefit;
	endif;

EndProcedure

&AtServer
Function documentReady ( Form )
	
	object = Form.Object;
	if ( object.Contract.IsEmpty () ) then
		return false;
	endif;
	ref = object.Ref;
	if ( TypeOf ( ref ) = Type ( "DocumentRef.SalesOrder" ) ) then
		return salesOrderReady ( ref );
	endif;
	return true;
	
EndFunction

&AtServer
Function salesOrderReady ( Ref )
	
	s = "
	|select top 1 1
	|from AccumulationRegister.SalesOrderDebts as Debts
	|where Debts.Recorder = &Ref
	|";
	q = new Query ( s );
	q.SetParameter ( "Ref", Ref );
	return not q.Execute ().IsEmpty ();
	
EndFunction

&AtServer
Function getDebt ( Object )
	
	ref = Object.Ref;
	type = TypeOf ( ref ); 
	if ( type = Type ( "DocumentRef.SalesOrder" ) ) then
		register = "SalesOrderDebts";
		discount = "Discounts";
		resource = "Payment";
		factor = 1;
	elsif ( type = Type ( "DocumentRef.PurchaseOrder" ) ) then
		register = "PurchaseOrderDebts";
		discount = "VendorDiscounts";
		resource = "Payment";
		factor = 1;
	elsif ( type = Type ( "DocumentRef.Invoice" ) ) then
		register = "InvoiceDebts";
		discount = "Discounts";
		resource = "Amount";
		factor = 1;
	elsif ( type = Type ( "DocumentRef.Return" ) ) then
		register = "InvoiceDebts";
		discount = "Discounts";
		resource = "Amount";
		factor = -1;
	elsif ( type = Type ( "DocumentRef.VendorInvoice" ) ) then
		register = "VendorInvoiceDebts";
		discount = "VendorDiscounts";
		resource = "Amount";
		factor = 1;
	elsif ( type = Type ( "DocumentRef.VendorReturn" ) ) then
		register = "VendorInvoiceDebts";
		discount = "VendorDiscounts";
		resource = "Amount";
		factor = -1;
	endif;
	s = "select " + resource + "Balance as Amount, isnull ( Discounts.Amount, 0 ) as Benefit from AccumulationRegister."
		+ register + ".Balance ( , Document = &Document )
		|left join (
		|	select sum ( Discounts.Amount ) as Amount
		|	from (
		|		select Discounts.Amount as Amount
		|		from AccumulationRegister." + discount + " as Discounts
		|		where Discounts.Document = &Document
		|		union all
		|		select - Discounts.Amount
		|		from AccumulationRegister." + discount + " as Discounts
		|		where Discounts.Detail = &Document
		|	) as Discounts
		|) as Discounts
		|on true";
	q = new Query ( s );
	q.SetParameter ( "Document", ref );
	table = q.Execute ().Unload ();
	result = new Structure ( "Debt, Benefit", 0, 0 );
	if ( table.Count () > 0 ) then
		row = table [ 0 ];
		result.Debt = row.Amount * factor;
		result.Benefit = row.Benefit;
	endif;
	return result;
	
EndFunction

&AtServer
Function getAdvance ( Object )
	
	ref = Object.Ref;
	type = TypeOf ( ref ); 
	if ( type = Type ( "DocumentRef.Invoice" )
		or type = Type ( "DocumentRef.Return" ) ) then
		register = "Debts";
		orderRegister = "SalesOrderDebts";
		discount = "Discounts";
		orders = ? ( type = Type ( "DocumentRef.Invoice" ), getOrders ( Object, false ), undefined );
	elsif ( type = Type ( "DocumentRef.VendorInvoice" )
	 	or type = Type ( "DocumentRef.VendorReturn" ) ) then
		register = "VendorDebts";
		orderRegister = "PurchaseOrderDebts";
		discount = "VendorDiscounts";
		orders = ? ( type = Type ( "DocumentRef.VendorInvoice" ), getOrders ( Object, true ), undefined );
	endif;
	if ( orders = undefined
		or orders.Count () = 0 ) then
		s = "select OverpaymentBalance as Amount, 0 as Benefit from AccumulationRegister."
			+ register + ".Balance ( , Contract = &Contract )";
	else
		s = "select OverpaymentBalance as Amount, isnull ( Discounts.Amount, 0 ) as Benefit from AccumulationRegister."
			+ orderRegister + ".Balance ( , Document in ( &Orders ) )
			|left join (
			|	select sum ( Discounts.Amount ) as Amount
			|	from (
			|		select Discounts.Amount as Amount
			|		from AccumulationRegister." + discount + " as Discounts
			|		where Discounts.Document in ( &Orders )
			|		union all
			|		select - Discounts.Amount
			|		from AccumulationRegister." + discount + " as Discounts
			|		where Discounts.Detail in ( &Orders )
			|	) as Discounts
			|) as Discounts
			|on true";
	endif;
	q = new Query ( s );
	q.SetParameter ( "Contract", Object.Contract );
	q.SetParameter ( "Orders", orders );
	table = q.Execute ().Unload ();
	result = new Structure ( "Advance, Benefit", 0, 0 );
	if ( table.Count () > 0 ) then
		row = table [ 0 ];
		result.Advance = row.Amount;
		result.Benefit = row.Benefit;
	endif;
	return result;
	
EndFunction

Procedure CalcBalanceDue ( Form ) export

	object = Form.Object;
	Form.BalanceDue = object.ContractAmount - Form.PaymentsApplied - Form.Benefit;
	
EndProcedure

&AtServer
Procedure SetPaidPercent ( Form ) export
	
	composer = Form.List.SettingsComposer;
	fields = composer.Settings.UserFields.Items;
	percent = fields.Add ( Type ( "DataCompositionUserFieldExpression" ) );
	percent.SetDetailRecordExpression ( "case PaidPercent when 0 then """" else String ( PaidPercent ) + ""%"" end");
	inProgress = fields.Add ( Type ( "DataCompositionUserFieldExpression" ) );
	inProgress.SetDetailRecordExpression ( "not Paid");
	item = composer.FixedSettings.ConditionalAppearance.Items.Add ();
	item.Fields.Items.Add ().Field = new DataCompositionField ( "PaidPercent" );
	set = item.Appearance;
	set.SetParameterValue ( "Text", new DataCompositionField ( percent.DataPath ) );
	set.SetParameterValue ( "Show", new DataCompositionField ( inProgress.DataPath ) );
	
EndProcedure

&AtServer
Procedure SetShippedPercent ( Form ) export
	
	composer = Form.List.SettingsComposer;
	fields = composer.Settings.UserFields.Items;
	percent = composer.Settings.UserFields.Items.Add ( Type ( "DataCompositionUserFieldExpression" ) );
	percent.SetDetailRecordExpression ( "case ShippedPercent when 0 then """" else String ( ShippedPercent ) + ""%"" end");
	inProgress = fields.Add ( Type ( "DataCompositionUserFieldExpression" ) );
	inProgress.SetDetailRecordExpression ( "not Shipped");
	item = composer.FixedSettings.ConditionalAppearance.Items.Add ();
	item.Fields.Items.Add ().Field = new DataCompositionField ( "ShippedPercent" );
	set = item.Appearance;
	set.SetParameterValue ( "Text", new DataCompositionField ( percent.DataPath ) );
	set.SetParameterValue ( "Show", new DataCompositionField ( inProgress.DataPath ) );
	
EndProcedure
