package body HashFunctions is

   ---------------
   -- GenRandom --
   ---------------

   function GenRandom (R : In Out Integer) return Integer is
   begin
      R := (5*R);
      R := R mod(2**9);
      if R = 1 then
         return R;
      end if;
      return R/4;
   end GenRandom;

   ---------------------
   -- StringtoHashKey --
   ---------------------

   function StringtoHashKey (STRHash : String) return Integer is
      pragma Suppress(Overflow_check);
      KeyValue : Long_Integer;
      Key : Integer;
      STRtemp : BString.Bounded_String := BString.To_Bounded_String(STRHash);
      function ConvertString is new Ada.Unchecked_Conversion(String,Long_Integer);
      function ConvertLongInt is new Ada.Unchecked_Conversion(Long_Integer,Integer);
      STR34, STR89 : String (1..2);
      Char1 : String (1..1);
   begin
      STR34 := BString.slice(Source => STRtemp,
                            Low    => 3,
                            High   => 4);
      STR89 := BString.slice(Source => STRtemp,
                             Low    => 8,
                            High   => 9);
      Char1 := BString.Slice(Source => STRtemp,
                             Low    => 1,
                             High   => 1);
      KeyValue := ((ConvertString(STRHash)*33)) mod 128;
      Key:= ConvertLongInt(KeyValue);
      return Key;
   end StringtoHashKey;

   --------------------
   -- TheoreticalNum --
   --------------------

   function TheoreticalNum
     (Keys : Integer;
      TableSize : Integer;
      probeUse : probemethod)
      return Float
   is
      use CEF;
      loadfactor : Float;
      TheorNumProbes : Float;
   begin
      if probeUse = Linear then
         loadfactor := (Float(Keys)/Float(TableSize));
         TheorNumProbes := ((1.0-loadfactor)/2.0)/(1.0-loadfactor);
      else
         loadfactor := (Float(Keys)/Float(TableSize));
         TheorNumProbes := -(1.0-loadfactor)*(Log(1.0-loadfactor));
      end if;
         return TheorNumProbes;
   end TheoreticalNum;

   --------------
   -- MinProbe --
   --------------

   function MinProbe
     (MainArr : MainArray;
      StartPos : Integer;
      EndPos : Integer)
      return Integer
   is
      minVal : Integer := MainArr(StartPos).Probes;
      Rspace : Integer := EndPos - StartPos;
   begin
      for I in Integer range 1..Rspace loop
         if MainArr(StartPos+I).Probes < minVal then
            minVal := MainArr(StartPos + I).Probes;
         end if;
      end loop;
      return minVal;
   end MinProbe;

   --------------
   -- MaXProbe --
   --------------

   function MaXProbe
     (MainArr : MainArray;
      StartPos : Integer;
      EndPos : Integer)
      return Integer
   is
      MaxVal : Integer := MainArr(StartPos).Probes;
      Rspace : Integer := EndPos - StartPos;
   begin
      for I in Integer range 1..Rspace loop
         if MainArr(StartPos + I).Probes > MaxVal then
            MaxVal := MainArr(StartPos + I).Probes;
         end if;
      end loop;
      return MaxVal;
   end MaXProbe;

   --------------
   -- AvgProbe --
   --------------

   function AvgProbe
     (MainArr : MainArray;
      StartPos : Integer;
      EndPos : Integer)
      return Float
   is
      Total : Integer := 0;
      RSpace : Integer := Endpos - StartPos;
      Avg : Float;
   begin
      for I in Integer range 1..RSpace loop
         Total := Total + MainArr(StartPos + I).Probes;
      end loop;
      Avg := (Float(Total)/Float(RSpace));
      return Avg;
   end AvgProbe;

   ---------------
   -- InsertRan --
   ---------------

   procedure InsertRan (Word : String) is
      numProbes : Integer := 1;
      R : Integer := 1;
      HashKey : Integer;
      TempData : InData;
   begin
     HashKey := StringtoHashKey(Word);
     TempData.InitialAddress := HashKey;

      while MainArr(HashKey).Key /= 0 loop
         HashKey := GenRandom(R);
         numProbes := numProbes + 1;
      end loop;

      TempData.Key:= HashKey;
      TempData.Probes := numProbes;
      TempData.Data := Word;
      MainArr(HashKey) := TempData;

   end InsertRan;

   ---------------
   -- InsertLin --
   ---------------

   procedure InsertLin (Word :String) is
      NumProbes : Integer := 1;
      HashKey : Integer;
      TempData : InData;
   begin
      HashKey := StringtoHashKey(Word);
      TempData.InitialAddress := HashKey;

      while MainArr(HashKey).Key /= 0 loop
         HashKey := HashKey + 1;
         NumProbes := NumProbes+1;
         if HashKey > 128 then
            HashKey := 1;
         end if;
      end loop;
      TempData.Key := HashKey;
      TempData.Probes := NumProbes;
      TempData.Data := Word;
      MainArr(HashKey) := TempData;
   end InsertLin;

   -------------------
   -- HashFunctions --
   -------------------

   procedure HashFunctions
     (CapItemsPercent : Integer;
      Probeuse : probemethod)
   is
      InputItemsarr : SArray;
     -- TempString : String (1..16);
   begin
       Open(File => InputFile,
           Mode => In_File,
           Name => FileName);
      for I in Integer range 1..128 loop
         InputItemsarr(I) := Get_Line(InputFile);
      end loop;
      Close(File => InputFile);

      if CapItemsPercent = 90 then --90% full
         Cap90(ItemList => InputItemsarr,ProbeUse => Probeuse);
      elsif CapItemsPercent = 50 then --half
         Cap50(ItemList => InputItemsarr,ProbeUse => Probeuse);
      else -- all 128
         AddMain(ItemList => InputItemsarr,ProbeUse => Probeuse);
      end if;

      DisplayTable(Probeuse, MainArr);
   end HashFunctions;

   -------------
   -- AddMain --
   -------------

   procedure AddMain (ItemList : SArray; ProbeUse : probemethod) is
      Word : String(1..16);
   begin
      for I in Integer range 1..ItemList'length loop
         word := ItemList(I);
         if ProbeUse = Linear then
            InsertLin(Word => Word);
         else
            InsertRan(Word => Word);
         end if;
      end loop;
   end AddMain;

   -----------
   -- Cap50 --
   -----------

   procedure Cap50 (ItemList : SArray; ProbeUse : probemethod) is
      Word : String (1..16);
   begin
      for I in Integer range 1..64 loop
         Word := ItemList(I);
         if ProbeUse = Linear then
            InsertLin(Word);
         else
            InsertRan(Word);
         end if;
      end loop;
   end Cap50;

   -----------
   -- Cap90 --
   -----------

   procedure Cap90 (ItemList : SArray; ProbeUse : probemethod) is
      Word : String (1..16);
   begin
      for I in Integer range 1..115 loop
         Word := ItemList(I);
         if ProbeUse = Linear then
            InsertLin(Word);
         else
            InsertRan(Word);
         end if;
      end loop;
   end Cap90;

   -------------
   -- Display --
   -------------

   procedure DisplayTable (ProbeUse : probemethod; MainArr : MainArray) is
      I : Integer := 0;
      TheorNum : Float;
   begin
      while I /= 128 loop
         New_Line;
         Put("------------------------------------------------------------------------------------------------------------------------------"); New_Line;
         I:=I+1; Put(I); I:=I+1; Put("              |        "); Put(I); I:=I+1; Put("            |        "); Put(I); I:=I+1;
         Put("           |        ");Put(I); New_Line;

         Put(MainArr(I-3).Data); Put(MainArr(I-3).Probes); Put(" | ");
         Put(MainArr(I-2).Data); Put(MainArr(I-2).Probes); Put(" | ");
         Put(MainArr(I-1).Data); Put(MainArr(I-1).Probes); Put(" | ");
         Put(MainArr(I).Data); Put(MainArr(I).Probes); Put(" | "); New_Line;
      end loop;

      Put("First 30:");
      Stats(MainArr, 1, 30);
      New_Line;
      Put("Last 30:");
      Stats(MainArr, 98, 128);
      if Probeuse = Linear then
         TheorNum := TheoreticalNum(Keys      => 30,
                                    TableSize => 128,
                                    probeUse  => Linear);
         Put("Theoretical Number of Probes: ");
         Put(TheorNum);
      else
         TheorNum := TheoreticalNum(Keys      => 30,
                                    TableSize => 128,
                                    probeUse  => Random);
         Put("Theoretical Number of Probes: ");
         Put(TheorNum);
      end if;


   end DisplayTable;

   -----------
   -- Stats --
   -----------

   procedure Stats (MainArr : MainArray; lowest : Integer; highest : Integer) is
   begin
      Put("Minimun number of Probes: "); Put(MinProbe(MainArr, lowest, highest)); New_Line;
      Put("Maximum number of Probes: "); Put(MaXProbe(MainArr, lowest, highest)); New_Line;
      Put("Average number of Probes: "); Put(AvgProbe(MainArr, lowest, highest)); New_Line;
   end Stats;

end HashFunctions;
