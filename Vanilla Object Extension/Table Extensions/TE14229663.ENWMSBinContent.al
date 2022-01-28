/// <summary>
/// TableExtension EN WMS Bin Content (ID 14229236) extends Record Bin Content.
/// </summary>
tableextension 14229237 "WMS Bin Content ELA" extends "Bin Content"
{
    fields
    {

        field(14229220; "Blocked ELA"; Option)
        {
            OptionMembers = Open,Blocked,QC;
            DataClassification = ToBeClassified;
            Caption = 'Blocked';
        }
        field(14229221; "Blocked Reason ELA"; Code[10])
        {
            DataClassification = ToBeClassified;
            Caption = 'Blocked Reason';
        }
        field(14229222; "Item Description ELA"; Code[100])
        {
            Caption = 'Item Description';
            FieldClass = FlowField;
            CalcFormula = Lookup(Item.Description WHERE("No." = FIELD("Item No.")));
        }

    }

    /// <summary>
    /// CalcQtyAvailToPickUOM.
    /// </summary>
    /// <returns>Return value of type Decimal.</returns>
    procedure CalcQtyAvailToPickUOM(): Decimal
    var
        myInt: Integer;
        BinContent: Record "Bin Content";
        UOMMgt: codeunit "Unit of Measure Management";
        Item: Record Item;
    begin
        Item.Get("Item No.");
        IF Item."No." <> '' THEN
            EXIT(ROUND(CalcQtyAvailToPick(0) / UOMMgt.GetQtyPerUnitOfMeasure(Item, "Unit of Measure Code"), 0.00001));
    end;


    procedure CalcRemainingLife(): Integer
    begin
        //<<EN1.10
        //TR IF "Code Date" <> 0D THEN
        //TR    EXIT("Code Date" - TODAY)
        //TR ELSE
        //TR    EXIT(0);
        //>>EN1.10
    end;

}
