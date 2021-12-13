codeunit 14228901 "EN Sales Guide-Post (Yes/No)"
{
    TableNo = "Sales Header";

    trigger OnRun()
    begin
        SalesHeader.Copy(Rec);
        Code;
        Rec := SalesHeader;
    end;

    var
        Text000: Label '&Ship,&Invoice,Ship &and Invoice';
        Text001: Label 'Do you want to post shipment for %1 %2?';
        Text002: Label '&Receive,&Invoice,Receive &and Invoice';
        SalesHeader: Record "Sales Header";
        SalesPost: Codeunit "Sales-Post";
        Selection: Integer;

    local procedure "Code"()
    begin
        if not
               Confirm(
                 Text001, true,
                 SalesHeader."Document Type", SalesHeader."No.")
            then
            exit;
        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Order:
                begin
                    SalesHeader.Ship := true;
                    SalesHeader.Invoice := false;
                end else
        end;
        SalesPost.Run(SalesHeader);


        Commit;
    end;
}

