page 14228840 "Phys. Inv. Journal Details ELA"
{
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Phys. Inv. Journal Detail ELA";

    layout
    {
        area(content)
        {
            repeater(Control1102631000)
            {
                ShowCaption = false;
                field("Item No."; "Item No.")
                {
                    Visible = false;
                }
                field("Location Code"; "Location Code")
                {
                    Visible = false;
                }
                field("Quantity (Count)"; "Quantity (Count)")
                {
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                }
                field("Quantity (Base) (Count)"; "Quantity (Base) (Count)")
                {
                    Visible = false;
                }
                field(Description; Description)
                {
                }
                field("Date Created"; "Date Created")
                {
                    Visible = false;
                }
                field("Created By"; "Created By")
                {
                    Visible = false;
                }
                field("Last Date Modified"; "Last Date Modified")
                {
                    Visible = false;
                }
                field("Modified By"; "Modified By")
                {
                    Visible = false;
                }
            }
            group("Total Count")
            {
                Caption = 'Total Count';
                group(Control23019001)
                {
                    ShowCaption = false;
                    field(gdecTotalCount; gdecTotalCount)
                    {
                        Caption = 'Quantity (Base)';
                        DecimalPlaces = 0 : 5;
                        Editable = false;
                    }
                    field(gcodBaseUOM; gcodBaseUOM)
                    {
                        Caption = 'Base UOM';
                        Editable = false;
                    }
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        jfCalcTotals;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        lrecItemJnlLine: Record "Item Journal Line";
    begin
        "Journal Template Name" := GetFilter("Journal Template Name");
        "Journal Batch Name" := GetFilter("Journal Batch Name");

        if GetFilter("Item Jnl. Line No.") <> '' then
            Evaluate("Item Jnl. Line No.", GetFilter("Item Jnl. Line No."));

        if lrecItemJnlLine.Get("Journal Template Name", "Journal Batch Name", "Item Jnl. Line No.") then begin
            "Item No." := lrecItemJnlLine."Item No.";
            "Location Code" := lrecItemJnlLine."Location Code";
            "Unit of Measure Code" := lrecItemJnlLine."Unit of Measure Code";
        end;
    end;

    var
        gdecTotalCount: Decimal;
        gcodBaseUOM: Code[10];
        Text19019365: Label 'Total Count';

    [Scope('Internal')]
    procedure jfCalcTotals()
    var
        lrecPhysInvDetail: Record "Phys. Inv. Journal Detail ELA";
        lrecItemJnlLine: Record "Item Journal Line";
    begin
        lrecPhysInvDetail.SetCurrentKey("Journal Template Name", "Journal Batch Name", "Item Jnl. Line No.");

        lrecPhysInvDetail.SetRange("Journal Template Name", "Journal Template Name");
        lrecPhysInvDetail.SetRange("Journal Batch Name", "Journal Batch Name");
        lrecPhysInvDetail.SetRange("Item Jnl. Line No.", "Item Jnl. Line No.");

        lrecPhysInvDetail.CalcSums("Quantity (Base) (Count)");

        gdecTotalCount := lrecPhysInvDetail."Quantity (Base) (Count)";

        if lrecItemJnlLine.Get("Journal Template Name", "Journal Batch Name", "Item Jnl. Line No.") then
            gcodBaseUOM := lrecItemJnlLine."Unit of Measure Code";
    end;
}

