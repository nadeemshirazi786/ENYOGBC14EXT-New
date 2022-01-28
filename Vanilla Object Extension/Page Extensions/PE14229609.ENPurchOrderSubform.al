pageextension 14229609 "EN Purchase Order Subform" extends "Purchase Order Subform"
{

    layout
    {
        addafter(Quantity)
        {
            field("Pallet Count"; "Pallet Count ELA")
            {
                ApplicationArea = All;
                Visible = true;
            }
            field("Lot No."; "Lot No. ELA")
            {
                ApplicationArea = All;
                Visible = true;
            }
        }
        addlast(Control1)
        {
            field("Bottle Deposit"; "Bottle Deposit")
            {
                ApplicationArea = All;
            }
            field("Bottle Deposit Amount"; GetBottleAmount(Rec))
            {
                ApplicationArea = All;

            }
        }
        addafter("Deferral Code")
        {
            field("Shortcut EC Charge 1"; ShortcutECCharge[1])
            {
                ApplicationArea = All;
                Visible = false;
                AutoFormatExpression = "Currency Code";
                trigger OnDrillDown()
                begin
                    ValidateShortcutECChargeELA(1, ShortcutECCharge[1]);
                end;
            }
            field("Shortcut EC Charge 2"; ShortcutECCharge[2])
            {
                ApplicationArea = All;
                Visible = false;
                AutoFormatExpression = "Currency Code";
                trigger OnDrillDown()
                begin
                    ValidateShortcutECChargeELA(1, ShortcutECCharge[1]);
                end;
            }
            field("Shortcut EC Charge 3"; ShortcutECCharge[3])
            {
                ApplicationArea = All;
                Visible = false;
                AutoFormatExpression = "Currency Code";
                trigger OnDrillDown()
                begin
                    ValidateShortcutECChargeELA(1, ShortcutECCharge[1]);
                end;
            }
            field("Shortcut EC Charge 4"; ShortcutECCharge[4])
            {
                ApplicationArea = All;
                Visible = false;
                AutoFormatExpression = "Currency Code";
                trigger OnDrillDown()
                begin
                    ValidateShortcutECChargeELA(1, ShortcutECCharge[1]);
                end;
            }
            field("Shortcut EC Charge 5"; ShortcutECCharge[5])
            {
                ApplicationArea = All;
                Visible = false;
                AutoFormatExpression = "Currency Code";
                trigger OnDrillDown()
                begin
                    ValidateShortcutECChargeELA(1, ShortcutECCharge[1]);
                end;
            }
            field("Extra Charge"; "Extra Charge ELA")
            {
                ApplicationArea = All;
                trigger OnDrillDown()
                begin
                    //<<ENEC1.00
                    CurrPage.SAVERECORD;
                    COMMIT;
                    Rec.ShowExtraChargesELA;
                    ShowShortcutECChargeELA(ShortcutECCharge);
                    CurrPage.UPDATE(TRUE);
                    //>>ENEC1.00
                end;
            }
            field("Extra Charge Unit Cost"; ExtraChargeUnitCostELA)
            {
                ApplicationArea = All;
                Visible = false;
            }

            field("Line Amount Incl. Extra Charges"; LineAmountWithExtraChargeELA)
            {
                ApplicationArea = All;

            }
            field("List Cost"; Rec."List Cost ELA")
            {
                ApplicationArea = All;
            }
            field("Upcharge Amount"; Rec."Upcharge Amount ELA")
            {
                ApplicationArea = All;
            }
            field("Billback Amount"; Rec."Billback Amount ELA")
            {
                ApplicationArea = All;
            }
            field("Dicount 1 Amount"; Rec."Discount 1 Amount ELA")
            {
                ApplicationArea = All;
            }
            field("Freight Amount"; Rec."Freight Amount ELA")
            {
                ApplicationArea = All;
            }
            field("Unit Cost"; Rec."Unit Cost")
            {
                ApplicationArea = All;
            }
            field("Total P.O. Cost"; isCalcPOCost)
            {
                ApplicationArea = All;
            }
        }
        modify(Type)
        {
            trigger OnAfterValidate()
            begin
                SetLotFields;
            end;
        }
		addafter("Unit of Measure Code")
        {

            field("Vendor Lot No."; "Vendor Lot No. ELA")
            {
                Caption = 'Vendor Lot No.';
                ApplicationArea = All;
            }
            field("Vendor Item Barcode ELA"; "Vendor Item Barcode ELA")
            {
                Caption = 'Vendor Item Barcode';
                ApplicationArea = All;
            }
            field("Outstanding Quantity"; "Outstanding Quantity")
            {
                ApplicationArea = All;
            }

        }
    }
    actions
    {
        addafter(DocAttach)
        {
            action("E&xtra Charge")
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                begin
                    ShowExtraChargesELA;
                end;
            }
        }

    }
    procedure SetLotFields()
    var
        ProcessFns: Codeunit "Process 800 Functions ELA";
        P800Globals: Codeunit "Process 800 System Globals ELA";
    begin
        LotEditable := ProcessFns.TrackingInstalled AND ("Lot No. ELA" <> P800Globals.MultipleLotCode) AND (Type = Type::Item);
    end;

    procedure isCalcPOCost(): Decimal
    begin
        IF Quantity <> 0 THEN
            EXIT("Line Amount" / Quantity);
        EXIT(0);
    end;
	procedure SetLocFilter(LocationCode: code[10])
    var
    begin
        FILTERGROUP(2);
        SETRANGE("Location Code", LocationCode);
        FILTERGROUP(0);
        CurrPage.Update();
    end;

    var
        ShortcutECCharge: Array[5] of Decimal;
        LotEditable: Boolean;
}