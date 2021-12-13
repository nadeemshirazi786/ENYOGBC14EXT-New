page 14229435 "Purch. Order Lines ELA"
{
    // ENRE1.00 2021-09-08 AJ
    // 
    // ENRE1.00
    //    - new form to handle item charges for purchase order lines


    Editable = false;
    PageType = List;
    SourceTable = "Purchase Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                    HideValue = "Document No.HideValue";
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Buy-from Vendor No."; "Buy-from Vendor No.")
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure"; "Unit of Measure")
                {
                    ApplicationArea = All;
                }
                field("Direct Unit Cost"; "Direct Unit Cost")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Unit Cost (LCY)"; "Unit Cost (LCY)")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Indirect Cost %"; "Indirect Cost %")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Quantity Invoiced"; "Quantity Invoiced")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Vendor Item No."; "Vendor Item No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Unit Cost"; "Unit Cost")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Prod. Order No."; "Prod. Order No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Qty. per Unit of Measure"; "Qty. per Unit of Measure")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Line")
            {
                Caption = '&Line';
                action("Show Document")
                {
                    ApplicationArea = All;
                    Caption = 'Show Document';
                    Image = View;
                    ShortCutKey = 'Shift+F7';

                    trigger OnAction()
                    var
                        lrecPurchHeader: Record "Purchase Header";
                    begin
                        //<ENRE1.00>
                        lrecPurchHeader.Get("Document Type", "Document No.");
                        PAGE.Run(PAGE::"Purchase Order", lrecPurchHeader);
                        //</ENRE1.00>
                    end;
                }
                action(Dimensions)
                {
                    ApplicationArea = All;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';

                    trigger OnAction()
                    begin
                        ShowDimensions;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        "Document No.HideValue" := false;
        DocumentNoOnFormat;
    end;

    trigger OnInit()
    begin
        CurrPage.LookupMode := true;
    end;

    trigger OnOpenPage()
    begin
        //<ENRE1.00>
        FilterGroup(2);
        SetRange("Document Type", "Document Type"::Order);
        SetRange(Type, Type::Item);
        SetFilter(Quantity, '<>0');
        FilterGroup(0);
        //</ENRE1.00>
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = ACTION::LookupOK then
            LookupOKOnPush;
    end;

    var
        grecFromPurchOrderLine: Record "Purchase Line";
        grecTempPurchOrderLine: Record "Purchase Line" temporary;
        ItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)";
        AssignItemChargePurch: Codeunit "Item Charge Assgnt. (Purch.)";
        AssignItemChargePurch2: Codeunit "Item Charge Assgnt (Purch) ELA";

        UnitCost: Decimal;
        [InDataSet]
        "Document No.HideValue": Boolean;
        [InDataSet]
        "Document No.Emphasize": Boolean;
        goptOrigDocType: Option;
        gcodOrigDocNo: Code[20];
        gintOrigDocLineNo: Integer;


    procedure Initialize(NewItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)"; NewUnitCost: Decimal)
    begin
        //<ENRE1.00>
        ItemChargeAssgntPurch := NewItemChargeAssgntPurch;
        UnitCost := NewUnitCost;
        //</ENRE1.00>
    end;

    local procedure IsFirstDocLine(): Boolean
    var
        lrecPurchOrderLine: Record "Purchase Line";
    begin
        //<ENRE1.00>
        grecTempPurchOrderLine.Reset;
        grecTempPurchOrderLine.CopyFilters(Rec);
        grecTempPurchOrderLine.SetRange("Document Type", "Document Type");
        grecTempPurchOrderLine.SetRange("Document No.", "Document No.");

        if not grecTempPurchOrderLine.Find('-') then begin
            FilterGroup(2);
            lrecPurchOrderLine.CopyFilters(Rec);
            FilterGroup(0);

            lrecPurchOrderLine.SetRange("Document No.", "Document No.");
            lrecPurchOrderLine.Find('-');

            grecTempPurchOrderLine := lrecPurchOrderLine;

            grecTempPurchOrderLine.Insert;
        end;

        if "Line No." = grecTempPurchOrderLine."Line No." then
            exit(true);
        //</ENRE1.00>
    end;

    local procedure LookupOKOnPush()
    begin
        //<ENRE1.00>
        grecFromPurchOrderLine.Copy(Rec);

        CurrPage.SetSelectionFilter(grecFromPurchOrderLine);

        if grecFromPurchOrderLine.Find('-') then begin
            ItemChargeAssgntPurch."Unit Cost" := UnitCost;
            AssignItemChargePurch2.CreatePurchOrderChargeAssgnt(grecFromPurchOrderLine, ItemChargeAssgntPurch);
        end;
        //</ENRE1.00>
    end;

    local procedure DocumentNoOnFormat()
    begin
        if IsFirstDocLine then
            "Document No.Emphasize" := true
        else
            "Document No.HideValue" := true;
    end;
}

