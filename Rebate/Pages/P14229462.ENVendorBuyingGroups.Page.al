page 14229462 "Vendor Buying Groups ELA"
{
    // ENRE1.00 2021-09-08 AJ
    // ENRE1.00
    //    - new form
    // 
    // ENRE1.00
    //   
    //     added GetSelectionFilter; modified version of "Customer Price Groups"::GetSelectionFilter
    //       accessor used by Sales Prices form filter lookup
    Caption = 'Vendor Buying Groups';
    ApplicationArea = All;
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Vendor Buying Group ELA";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control23019000)
            {
                ShowCaption = false;
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Rebate Accrual Vendor No."; "Rebate Accrual Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Rebate Accrual Vendor Name"; "Rebate Accrual Vendor Name")
                {
                    ApplicationArea = All;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field("Name 2"; "Name 2")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Address; Address)
                {
                    ApplicationArea = All;
                }
                field("Address 2"; "Address 2")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(City; City)
                {
                    ApplicationArea = All;
                }
                field(County; County)
                {
                    ApplicationArea = All;
                }
                field("Post Code"; "Post Code")
                {
                    ApplicationArea = All;
                }
                field("Country/Region Code"; "Country/Region Code")
                {
                    ApplicationArea = All;
                }
                field(Contact; Contact)
                {
                    ApplicationArea = All;
                }
                field("Primary Contact No."; "Primary Contact No.")
                {
                    ApplicationArea = All;
                }
                field("Phone No."; "Phone No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    [Scope('Internal')]
    procedure GetSelectionFilter(): Code[80]
    var
        CustBuyingGr: Record "Customer Buying Group ELA";
        FirstCustBuyingGr: Code[30];
        LastCustBuyingGr: Code[30];
        SelectionFilter: Code[250];
        CustBuyingGrCount: Integer;
        More: Boolean;
    begin
        CurrPage.SetSelectionFilter(CustBuyingGr);
        CustBuyingGrCount := CustBuyingGr.Count;
        if CustBuyingGrCount > 0 then begin
            CustBuyingGr.Find('-');
            while CustBuyingGrCount > 0 do begin
                CustBuyingGrCount := CustBuyingGrCount - 1;
                CustBuyingGr.MarkedOnly(false);
                FirstCustBuyingGr := CustBuyingGr.Code;
                LastCustBuyingGr := FirstCustBuyingGr;
                More := (CustBuyingGrCount > 0);
                while More do
                    if CustBuyingGr.Next = 0 then
                        More := false
                    else
                        if not CustBuyingGr.Mark then
                            More := false
                        else begin
                            LastCustBuyingGr := CustBuyingGr.Code;
                            CustBuyingGrCount := CustBuyingGrCount - 1;
                            if CustBuyingGrCount = 0 then
                                More := false;
                        end;
                if SelectionFilter <> '' then
                    SelectionFilter := SelectionFilter + '|';
                if FirstCustBuyingGr = LastCustBuyingGr then
                    SelectionFilter := SelectionFilter + FirstCustBuyingGr
                else
                    SelectionFilter := SelectionFilter + FirstCustBuyingGr + '..' + LastCustBuyingGr;
                if CustBuyingGrCount > 0 then begin
                    CustBuyingGr.MarkedOnly(true);
                    CustBuyingGr.Next;
                end;
            end;
        end;
        exit(SelectionFilter);
    end;
}

