codeunit 14229417 "Sales Info Pane Managment ELA"
{
    // ENRE1.00 2021-09-08 AJ
    trigger OnRun()
    begin

    end;

    procedure CalcRebate(precSalesHeader: Record "Sales Header"; poptType: Option All,"Off-Invoice Only","Non Off-Invoice Only"): Decimal
    var
        lrecRebateEntry: Record "Rebate Entry ELA";
        ldecRebate: Decimal;
    begin
        Clear(ldecRebate);
        lrecRebateEntry.SetCurrentKey("Functional Area", "Source Type", "Source No.");
        lrecRebateEntry.SetRange("Functional Area", lrecRebateEntry."Functional Area"::Sales);
        lrecRebateEntry.SetRange("Source Type", precSalesHeader."Document Type");
        lrecRebateEntry.SetRange("Source No.", precSalesHeader."No.");

        case poptType of
            poptType::All:
                begin
                    lrecRebateEntry.SetRange("Rebate Type");
                end;
            poptType::"Off-Invoice Only":
                begin
                    lrecRebateEntry.SetRange("Rebate Type", lrecRebateEntry."Rebate Type"::"Off-Invoice");
                end;
            poptType::"Non Off-Invoice Only":
                begin
                    lrecRebateEntry.SetFilter("Rebate Type", '<>%1', lrecRebateEntry."Rebate Type"::"Off-Invoice");
                end;
        end;

        if lrecRebateEntry.IsEmpty then
            exit(0);

        if lrecRebateEntry.FindSet then begin
            repeat
                ldecRebate := ldecRebate + lrecRebateEntry."Amount (DOC)";
            until lrecRebateEntry.Next = 0;
        end;
        ldecRebate := Round(ldecRebate, 0.01);
        exit(ldecRebate);
    end;


    procedure LookupRebate(precSalesHeader: Record "Sales Header"; poptType: Option All,"Off-Invoice Only","Non Off-Invoice Only")
    var
        lrecRebateEntry: Record "Rebate Entry ELA";
    begin
        lrecRebateEntry.SetRange("Functional Area", lrecRebateEntry."Functional Area"::Sales);
        lrecRebateEntry.SetRange("Source Type", precSalesHeader."Document Type");
        lrecRebateEntry.SetRange("Source No.", precSalesHeader."No.");

        case poptType of
            poptType::All:
                begin
                    lrecRebateEntry.SetRange("Rebate Type");
                end;
            poptType::"Off-Invoice Only":
                begin
                    lrecRebateEntry.SetRange("Rebate Type", lrecRebateEntry."Rebate Type"::"Off-Invoice");
                end;
            poptType::"Non Off-Invoice Only":
                begin
                    lrecRebateEntry.SetFilter("Rebate Type", '<>%1', lrecRebateEntry."Rebate Type"::"Off-Invoice");
                end;
        end;

        PAGE.RunModal(PAGE::"Rebate Entries ELA", lrecRebateEntry);
        //>>ENRE1.00
    end;

    var
        myInt: Integer;
}