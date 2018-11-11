with Ada.Unchecked_Conversion;
with Ada.Strings.Bounded;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;

generic
package HashFunctions is

   package BString is new Ada.Strings.Bounded.Generic_Bounded_Length(Max => 20);
   FileName : String := "Words200D16.txt";
   InputFile : Ada.Text_IO.File_Type;
   
   ItemKnt, ArrSize : Integer;
   
   type probemethod is (Linear, Random);
   package ProbeIO is new Ada.Text_IO.Enumeration_IO(probemethod); use ProbeIO;
   package LongIntIO is new Ada.Text_IO.Integer_IO(Standard.Long_Integer); use LongIntIO;
   package FloatIO is new Ada.Text_IO.Float_IO(Float); use FloatIO;
   package IntegerIO is new Ada.Text_IO.Integer_IO(Integer); use IntegerIO;
   package CEF renames Ada.Numerics.Elementary_Functions;
  -- package ComplexNum is new ada.Numerics.Generic_Complex_Elementary_Functions;
   
   type InData is record
      Key : Integer;
      InitialAddress : Integer;
      Probes : Integer;
      Data : String (1..16);
   end record;
   type MainArray is array (1..128) of InData;
   MainArr : MainArray := (others =>(Key => 0, InitialAddress => 0, Probes => 0, Data =>"                "));
   type SArray is array (1..128) of String (1..16);
   ItemHolder : SArray;
     
   function GenRandom (R : in out Integer) return Integer;
   function StringtoHashKey (STRHash : String) return Integer;
   function TheoreticalNum( Keys : Integer; TableSize : Integer; probeUse : probemethod) return Float;
   function MinProbe (MainArr : MainArray; StartPos : Integer; EndPos : Integer) return Integer;
   function MaXProbe (MainArr : MainArray; StartPos : Integer; EndPos : Integer) return Integer;
   function AvgProbe (MainArr : MainArray; StartPos : Integer; EndPos : Integer) return Float;
   procedure InsertRan (Word : String);
   procedure InsertLin (Word :String);
   procedure HashFunctions (CapItemsPercent : Integer; Probeuse : probemethod);
   procedure AddMain (ItemList : SArray; ProbeUse : probemethod);
   procedure Cap50 (ItemList : SArray; ProbeUse : probemethod);
   procedure Cap90 (ItemList : SArray; ProbeUse : probemethod);
   procedure DisplayTable (ProbeUse : probemethod; MainArr : MainArray);
   procedure Stats (MainArr : MainArray; lowest : Integer; highest : Integer);

end HashFunctions;
