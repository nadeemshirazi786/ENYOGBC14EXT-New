codeunit 14229407 "Purch Info Pane Management ELA"
{
    // ENRE1.00 2021-09-08 AJ
    trigger OnRun()
    begin

    end;

    procedure CalcRebate(precPurchHeader: Record "Purchase Header"; poptType: Option All,"Off-Invoice Only","Non Off-Invoice Only"): Decimal
    var
        lrecRebateEntry: Record "Rebate Entry ELA";
        ldecRebate: Decimal;
    begin
        //<ENRE1.00>
        lrecRebateEntry.SetRange("Functional Area", lrecRebateEntry."Functional Area"::Purchase);
        lrecRebateEntry.SetRange("Source Type", precPurchHeader."Document Type");
        lrecRebateEntry.SetRange("Source No.", precPurchHeader."No.");

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
        //</ENRE1.00>
    end;


    procedure LookupRebate(precPurchHeader: Record "Purchase Header"; poptType: Option All,"Off-Invoice Only","Non Off-Invoice Only")
    var
        lrecRebateEntry: Record "Rebate Entry ELA";
    begin
        //<ENRE1.00>
        lrecRebateEntry.SetRange("Functional Area", lrecRebateEntry."Functional Area"::Purchase);
        lrecRebateEntry.SetRange("Source Type", precPurchHeader."Document Type");
        lrecRebateEntry.SetRange("Source No.", precPurchHeader."No.");

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
        //</ENRE1.00>
    end;

    var
        myInt: Integer;
}