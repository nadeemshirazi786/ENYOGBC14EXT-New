codeunit 14228900 "EN Sales Guide - Order Entry"
{

    TableNo = "Sales Header";

    trigger OnRun()
    var
        SalesLine2: Record "Sales Line";
    begin

        TestField(Status, Status::Open);

        SalesGuideOrderEntryT.SetRange("Order No.", "No.");
        repeat
            if SalesGuideOrderEntryT.Quantity > 0 then begin
                // Create the Sales Line.
                /* NewSalesLine.SETRANGE("Document Type","Document Type");
                 NewSalesLine.SETRANGE("Document No.","No.");
                 IF NewSalesLine.FIND('+') THEN
                   NextLineNum := NewSalesLine."Line No." + 10000
                 ELSE
                   NextLineNum := 10000; */
                NewSalesLine.Init;
                NewSalesLine.Validate("Document Type", "Document Type");
                NewSalesLine.Validate("Document No.", "No.");
                NewSalesLine."Line No." := 0;   // NextLineNum;
                NewSalesLine.Validate(Type, NewSalesLine.Type::Item);
                NewSalesLine.Validate("No.", SalesGuideOrderEntryT."Item No.");
                NewSalesLine.Validate("Variant Code", SalesGuideOrderEntryT."Item Variant Code");
                NewSalesLine.Description := SalesGuideOrderEntryT.Description;
                if NewSalesLine."Unit of Measure" <> SalesGuideOrderEntryT."Sales Unit of Measure" then
                    NewSalesLine.Validate("Unit of Measure", SalesGuideOrderEntryT."Sales Unit of Measure");
                NewSalesLine.Validate(Quantity, SalesGuideOrderEntryT.Quantity);
                NewSalesLine.Validate("Unit Price", SalesGuideOrderEntryT."Unit Price");
                ///TMS 11-21-2015 Remove Country/Region of Origin Code after implementing Country/Region Code
                if SalesGuideOrderEntryT."Country/Region of Origin Code" <> '' then
                    NewSalesLine.Validate("Country/Reg of Origin Code ELA", SalesGuideOrderEntryT."Country/Region of Origin Code");

                SalesLine2.SetRange("Document Type", "Document Type");
                SalesLine2.SetRange("Document No.", "No.");
                if SalesLine2.Find('+') then
                    NextLineNum := SalesLine2."Line No." + 10000
                else
                    NextLineNum := 10000;
                NewSalesLine."Line No." := NextLineNum;
                NewSalesLine.Insert(true);
                // Clear the SalesGuideOrderEntryT.
                SalesGuideOrderEntryT.Quantity := 0;
                //SalesGuideOrderEntryT."Item Variant Code" := '';
                SalesGuideOrderEntryT.Modify(true);
            end
            else
                /*Do nothing*/
                    ;
        until SalesGuideOrderEntryT.Next = 0;

        Commit;

    end;

    procedure GetSupplyChainGroup(): Code[10]
    var
        SupplyChainGroupUser: Record "EN Supply Chain Group User";
    begin
        //<<TMS1.00
        SupplyChainGroupUser.Reset;
        SupplyChainGroupUser.SetRange("User ID", UserId);
        if SupplyChainGroupUser.FindFirst then
            exit(SupplyChainGroupUser."Supply Chain Group Code");
        //>>TMS1.00
    end;

    var
        NewSalesLine: Record "Sales Line";
        NextLineNum: Integer;
        SalesGuideOrderEntryT: Record "EN Sales Guide Order Entry";
}

