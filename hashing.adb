with Ada.Text_IO; Use Ada.Text_IO;
with Ada.Unchecked_Conversion;
with Ada.Strings.Bounded;
with HashFunctions;

procedure Hashing is
   package Hash90L is new HashFunctions; use Hash90L;
   package Hash90R is new HashFunctions; use Hash90R;
   package Hash50L is new HashFunctions; use Hash50L;
   package Hash50R is new HashFunctions; use Hash50R;

begin
   Put("Hashing with 90% Full Linear");
   Hash90L.HashFunctions(CapItemsPercent => 90,
                         Probeuse        => Linear);
   Put("Hashing with 90% Full Random");
   Hash90R.HashFunctions(CapItemsPercent => 90,
                         Probeuse        => Random);
   Put("Hashing with 50% Full Random");
   Hash50R.HashFunctions(CapItemsPercent => 50,
                         Probeuse        => Random);
   Put("Hashing with 50% Linear");
   Hash50L.HashFunctions(CapItemsPercent => 50,
                         Probeuse        => Linear);
end Hashing;
