page 14228887 "EN Ship-To Addresses"
{
    Caption = 'Ship-to Address Lists';
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;

    SourceTable = "Ship-to Address";

    layout
    {
        area(content)
        {
            repeater(Control1102631000)
            {
                ShowCaption = false;
                field("Customer No."; "Customer No.")
                {
                }
                field("Code"; Code)
                {
                }
                field("Cash and Carry Location"; "Cash and Carry Location ELA")
                {
                    Visible = true;
                }
                field("Address"; GetAddress())
                {
                    Caption = 'Address';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }

    procedure GetAddress(): Text[256]
    var
        lrecSTA: Record "Ship-to Address";
        lcduFormatAddress: Codeunit "Format Address";
        ltxtAddArray: array[8] of Text[50];
        ltxtResult: Text[512];
        linti: Integer;
    begin
        if ("Customer No." = '') or (Code = '') then exit('');
        if not lrecSTA.Get("Customer No.", Code) then exit('');
        //lcduFormatAddress.ShipTo(ltxtAddArray, lrecSTA);TBR
        ltxtResult := ltxtAddArray[1];
        for linti := 2 to 8 do begin
            if ltxtAddArray[linti] <> '' then
                if StrLen(ltxtResult + ', ' + ltxtAddArray[linti]) <= MaxStrLen(ltxtResult) then
                    ltxtResult += ', ' + ltxtAddArray[linti];
        end;
        exit(ltxtResult);
    end;
}

