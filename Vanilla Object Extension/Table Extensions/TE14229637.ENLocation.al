tableextension 14229637 "EN LT Location EXT ELA" extends Location
{
    fields
    {
        field(14228880; "Allow Multi-UOM Bin Contnt ELA"; Boolean)
        {
            Caption = 'Allow Multi-UOM Bin Content';
            DataClassification = ToBeClassified;
        }
        field(50000; "Item List Matrix ELA"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }

    procedure LocationType(): Integer
    begin
        IF "Directed Put-away and Pick" THEN
            EXIT(3)
        ELSE
            IF "Require Pick" THEN
                EXIT(2)
            ELSE
                EXIT(1);
    end;




}