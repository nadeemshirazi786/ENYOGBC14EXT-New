page 14228886 "EM Customer Number"
{
    PageType = StandardDialog;
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            field(CustNo; CustNo)
            {
                Caption = 'Customer No.';
                TableRelation = Customer;

                trigger OnValidate()
                begin
                    CustNoOnAfterValidate;
                end;
            }
            field(ShipToCode; ShipToCode)
            {
                Caption = 'Ship To Address Code';
                TableRelation = "Ship-to Address";

                trigger OnLookup(var Text: Text): Boolean
                var
                    lfrmSTAList: Page "Ship-to Address List";
                    lfrmUDFShipTo: Page "EN Ship-To Addresses";
                begin
                    if CustNo = '' then begin
                        ShipToCode := '';
                        exit;
                    end;

                    Clear(lfrmUDFShipTo);
                    ShiptoAdd.SetRange("Customer No.", CustNo);
                    ShiptoAdd.SetFilter("Cash and Carry Location ELA", gcodUserSalesLocFilter);

                    // Customer %1 does not have any Cash & Carry Ship-To Addresses matching
                    // the Sales Location Filter "%2" in the User Setup record for %3.
                    if not ShiptoAdd.FindFirst then
                        Error(Text001, CustNo, grecUserSetup."Sales Location Filter ELA", UserId);  // Is this really an error?

                    lfrmUDFShipTo.SetRecord(ShiptoAdd);
                    lfrmUDFShipTo.SetTableView(ShiptoAdd);
                    lfrmUDFShipTo.LookupMode(true);
                    if lfrmUDFShipTo.RunModal <> ACTION::LookupOK then exit;
                    lfrmUDFShipTo.GetRecord(ShiptoAdd);
                    ShipToCode := ShiptoAdd.Code;
                end;
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        gblnShipToCodeRequired := true;

        if grecUserSetup.Get(UserId) then;
        gcodUserSalesLocFilter := grecUserSetup."Sales Location Filter ELA";
        if gcodUserSalesLocFilter = '' then
            Error(Text002, UserId);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin

        if (
          (CloseAction <> ACTION::OK)
        ) then begin
            CustNo := '';
            ShipToCode := '';
            exit(true);
        end;


        if not gblnShipToCodeRequired then exit(true);
        if CustNo = '' then exit(true);
        if ShipToCode <> '' then exit(true);

        ShiptoAdd.SetRange("Customer No.", CustNo);
        ShiptoAdd.SetFilter("Cash and Carry Location ELA", gcodUserSalesLocFilter);
        if not ShiptoAdd.FindFirst then exit(true);

        // A code is required, and at least one exists
        if Confirm('A Ship-to Address code is required.\Do you want to exit without choosing one?') then begin
            CustNo := '';
            exit(true);
        end;
        exit(false);
    end;

    var
        CustNo: Code[20];
        ShipToCode: Code[10];
        gblnShipToCodeRequired: Boolean;
        ShiptoAdd: Record "Ship-to Address";
        Text001: Label 'Customer %1 does not have any Cash & Carry Ship-To Addresses matching the Sales Location Filter "%2" in the User Setup record for %3.';
        gcodUserSalesLocFilter: Code[250];
        grecUserSetup: Record "User Setup";
        Text002: Label 'There is no Sales Location Filter set in the User Setup for %1';


    procedure ShipToCodeRequired(pblnShipToCodeRequired: Boolean)
    begin
        gblnShipToCodeRequired := pblnShipToCodeRequired;
    end;


    procedure GetCustomerNo(): Code[20]
    begin
        exit(CustNo);
    end;


    procedure GetShipToCode(): Code[10]
    begin
        exit(ShipToCode);
    end;

    local procedure CustNoOnAfterValidate()
    var
        lrecSTA: Record "Ship-to Address";
    begin
        if ShipToCode = '' then
            exit;
        if CustNo = '' then begin
            ShipToCode := '';
            exit;
        end;


        ShiptoAdd.Reset;
        ShiptoAdd.SetFilter("Customer No.", CustNo);
        ShiptoAdd.SetFilter(Code, gcodUserSalesLocFilter);
        if ShiptoAdd.FindFirst then begin
            ShipToCode := ShiptoAdd.Code;
            exit;
        end;
        Error(Text001, CustNo, gcodUserSalesLocFilter, UserId);
        CustNo := '';
    end;
}

