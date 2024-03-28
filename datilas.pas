{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit datilas;

{$warn 5023 off : no warning about unused units}
interface

uses
  uDatiDataset, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('uDatiDataset', @uDatiDataset.Register);
end;

initialization
  RegisterPackage('datilas', @Register);
end.
