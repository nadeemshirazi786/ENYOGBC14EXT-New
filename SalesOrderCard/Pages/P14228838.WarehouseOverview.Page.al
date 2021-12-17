page 23019749 "Warehouse Overview ELA"
{
    Caption = 'Warehouse Overview';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Warehouse Entry";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control23019001)
            {
                ShowCaption = false;
                field("Location Code"; "Location Code")
                {
                }
                field("Variant Code"; "Variant Code")
                {
                }
                field("Zone Code"; "Zone Code")
                {
                }
                field("Bin Code"; "Bin Code")
                {
                }
                field("Lot No."; "Lot No.")
                {
                }
                field("Serial No."; "Serial No.")
                {
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                }
                field(Quantity; Quantity)
                {
                }
                field("Qty. (Base)"; "Qty. (Base)")
                {
                }
                field(Cubage; Cubage)
                {
                }
                field(Weight; Weight)
                {
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        lnEntryNumber: Integer;
    begin
        SummarizedWhseEntry.Open;
        lnEntryNumber := 0;

        while SummarizedWhseEntry.Read do begin
            if SummarizedWhseEntry.Sum_Qty_Base > 0 then begin
                Init;
                lnEntryNumber += 1;
                "Entry No." := lnEntryNumber;
                "Item No." := SummarizedWhseEntry.Item_No;
                "Location Code" := SummarizedWhseEntry.Location_Code;
                "Variant Code" := SummarizedWhseEntry.Variant_Code;
                "Zone Code" := SummarizedWhseEntry.Zone_Code;
                "Bin Code" := SummarizedWhseEntry.Bin_Code;
                //"Container No." := SummarizedWhseEntry.Container_No;
                "Lot No." := SummarizedWhseEntry.Lot_No;
                "Serial No." := SummarizedWhseEntry.Serial_No;
                "Unit of Measure Code" := SummarizedWhseEntry.Unit_of_Measure_Code;
                Quantity := SummarizedWhseEntry.Sum_Quantity;
                "Qty. (Base)" := SummarizedWhseEntry.Sum_Qty_Base;
                Cubage := SummarizedWhseEntry.Sum_Cubage;
                Weight := SummarizedWhseEntry.Sum_Weight;
                Insert;
            end;
        end;
    end;

    var
        SummarizedWhseEntry: Query "Summarized Whse. Entry ELA";
}

