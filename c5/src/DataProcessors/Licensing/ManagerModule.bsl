���          
00000018 00000018 7fffffff 
G   �   ���@    ���
00000022 00000022 7fffffff 
�'.��C �'.��C     i m a g e     
00000299 00000299 7fffffff 
﻿{1,
{"Cmd",43,4294967295,
{1,3},
{3,2},
{18,0},
{19,1},
{5,0},
{1,3},
{16,0},
{1,4},
{3,2},
{18,0},
{20,0},
{1,4},
{1,6},
{22,0},
{1,10},
{18,0},
{19,1},
{5,0},
{1,10},
{18,0},
{21,1},
{5,0},
{1,10},
{17,0},
{45,0},
{39,26},
{1,12},
{22,0},
{1,16},
{18,0},
{19,1},
{5,0},
{1,16},
{18,0},
{21,2},
{5,0},
{1,16},
{17,0},
{45,0},
{39,40},
{1,18},
{22,0},
{22,0}
},
{"Const",3,
{"S","Exec"},
{"S","Check"},
{"S","Reset"}
},
{"Proc",4,
{"Exec",16,2,0,
{"Var",3,
{"Params",5,-1},
{"JobKey",5,-1},
{"obj",1,-1}
},
{"DefPrm",2,
{""},
{""}
}
},
{"Create",33,0,0},
{"Check",17,0,14},
{"Reset",17,0,28}
}
}
00000020 00000020 7fffffff 
�Y
P3C �'.��C     i n f o     
0000000f 00000200 7fffffff 
﻿{3,2,0,"",0}tion

Function Reset () export
	
	return Create ().Reset ();
	
EndFunction
dows_x86 ) then
		version = "CoreExtender";
	elsif ( type = PlatformType.Windows_x86_64 ) then
		version = "CoreExtender64";
	else
		raise Output.OSNotSupported ();
	endif;
	id = "AddIn.Core." + Name;
	try
		lib = new ( id );
	except
		load ( versiok.Add ( "Constant.License" );
	item.Mode = DataLockMode.Exclusive;
	item = lock.Add ( "Constant.ConnectionString" );
	item.Mode = DataLockMode.Exclusive