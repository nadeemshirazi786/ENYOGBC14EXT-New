report 14228851 "Close Sales Price ELA"
{

    Caption = 'Close Sales Prices';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;
    dataset
    {
        dataitem("Item Sales Price Calculation"; "EN Sales Price")
        {
            DataItemTableView = SORTING("Type", "Code", "Sales Type", "Sales Code", "Starting Date", "Variant Code", "Unit of Measure Code", "Minimum Quantity", "Contract Price", "Ship-From Location") ORDER(Ascending) WHERE("Reason Code" = FILTER(''));
            RequestFilterFields = "Code";
            trigger OnPreDataItem()
            begin
                grecIspcTEMP.DELETEALL;
                gintToDo1 := COUNT;
                gintDone1 := 0;
                gintToDo2 := 0;
                gintFixed := 0;
                OpenWindow;
                IF gblnUpdateDB THEN
                    gtxtUpdateText := 'Changes have been written to database'
                ELSE
                    gtxtUpdateText := 'Changes were *NOT* written to the database';

                gintDone1 := COUNT;
                SETFILTER("Ending Date", '%1', 0D);
            end;

            trigger OnAfterGetRecord()
            begin
                grecIspcTEMP := "Item Sales Price Calculation";
                IF grecIspcTEMP.INSERT THEN BEGIN
                    gintToDo2 += 1;
                END;
                UpdateWindow;
            end;
        }
        dataitem(Integer; Integer)
        {
            DataItemTableView = SORTING(Number) ORDER(Ascending);
            column("Updated"; 'Updated')
            {
            }
            column("Type"; FORMAT(grecIspcTEMP.Type))
            {
            }
            column("Code"; grecBestIspcTEMP."Sales Code")
            {
            }
            column("SalesType"; FORMAT(grecIspcTEMP."Sales Type"))
            {
            }
            column("SalesCode"; grecIspcTEMP."Sales Code")
            {
            }
            column("UpdStartingDate"; grecIspcTEMP."Starting Date")
            {
            }
            column("UpdEndingDate"; grecIspcTEMP."Ending Date")
            {
            }
            column("Source"; 'Source:')
            {
            }
            column("SourceType"; FORMAT(grecBestIspcTEMP.Type))
            {
            }
            column("SourceCode"; grecBestIspcTEMP."Sales Code")
            {
            }
            column("SourceSalesType"; FORMAT(grecBestIspcTEMP."Sales Type"))
            {
            }
            column("SourceSalesCode"; grecBestIspcTEMP."Sales Code")
            {
            }
            column("SourceStartingDate"; grecBestIspcTEMP."Starting Date")
            {
            }
            column("SourceEndingDate"; grecBestIspcTEMP."Ending Date")
            {
            }
            trigger OnPreDataItem()
            begin
                IF gintToDo2 = 0 THEN
                    CurrReport.BREAK;
                SETRANGE(Number, 1, gintToDo2);
                grecIspcTEMP.FINDFIRST;
            end;

            trigger OnAfterGetRecord()
            var
                lrecPurchPrice: Record "Purchase Price";
                lrecItemSalesPriceCalc: Record "EN Sales Price";
            begin
                IF Number > 1 THEN
                    grecIspcTEMP.NEXT;

                // For each one, find the record with the Starting Date closest to, but after
                // the Starting Date of the one we are trying to fix
                WITH lrecItemSalesPriceCalc DO BEGIN
                    gdatNewEndDate := 0D;
                    gblnFixed := FALSE;
                    RESET;

                    SETFILTER(Type, '%1', grecIspcTEMP.Type);
                    SETFILTER(Code, grecIspcTEMP.Code);
                    SETFILTER("Sales Type", '%1', grecIspcTEMP."Sales Type");
                    SETFILTER("Sales Code", grecIspcTEMP."Sales Code");
                    //SETFILTER("Starting Date",grecIspcTEMP."Starting Date");
                    SETFILTER("Variant Code", grecIspcTEMP."Variant Code");
                    SETFILTER("Unit of Measure Code", grecIspcTEMP."Unit of Measure Code");
                    SETFILTER("Minimum Quantity", '%1', grecIspcTEMP."Minimum Quantity");
                    SETFILTER("Contract Price", '%1', grecIspcTEMP."Contract Price");
                    SETFILTER("Ship-From Location", grecIspcTEMP."Ship-From Location");
                    // But only records without an Ending Date
                    SETFILTER("Ending Date", '%1', 0D);
                    // And a Starting Date after 'this' record's Starting Date
                    SETFILTER("Starting Date", '>%1', grecIspcTEMP."Starting Date");

                    //CCDP20130110
                    //SETFILTER("Purchase Rebate No.",'%1','');  // Why field is missing YOG not in ONFC?? Ask Dave P
                    SETFILTER("Reason Code", '%1', '');

                    IF FINDFIRST THEN BEGIN
                        CLEAR(grecBestIspcTEMP);
                        grecBestIspcTEMP."Starting Date" := 29991231D;
                        REPEAT
                            IF "Starting Date" < grecBestIspcTEMP."Starting Date" THEN
                                grecBestIspcTEMP := lrecItemSalesPriceCalc;
                        UNTIL NEXT = 0;
                        // Did we find a record?
                        IF grecBestIspcTEMP."Starting Date" <> 29991231D THEN BEGIN
                            // Get the 'real' record we are trying to fix
                            RESET;

                            GET(
                              grecIspcTEMP.Type,
                              grecIspcTEMP.Code,
                              grecIspcTEMP."Sales Type",
                              grecIspcTEMP."Sales Code",
                              grecIspcTEMP."Starting Date",
                              grecIspcTEMP."Variant Code",
                              grecIspcTEMP."Unit of Measure Code",
                              grecIspcTEMP."Minimum Quantity",
                              grecIspcTEMP."Contract Price",
                              grecIspcTEMP."Ship-From Location"
                            );

                            // Set ending date to one day before starting date
                            "Ending Date" := CALCDATE('-1D', grecBestIspcTEMP."Starting Date");
                            IF gblnUpdateDB THEN
                                MODIFY;
                            gdatNewEndDate := "Ending Date";
                            gblnFixed := TRUE;
                            gintFixed += 1;
                            UpdateWindow;
                        END;
                    END;
                END;
            end;
        }
    }


    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {

                }
            }
        }

        actions
        {
            area(processing)
            {
                action(ActionName)
                {
                    ApplicationArea = All;

                }
            }
        }
    }
    trigger OnInitReport()
    begin
        gblnUpdateDB := true;
    end;

    procedure OpenWindow()
    begin
        IF NOT GUIALLOWED THEN EXIT;
        gdlgWindow.OPEN(
          'Price Records In Filter       #1####\\' +
          'Prices With No End Date           #2####\\' +
          'Price Records ''Closed''     #3####'
        );
    end;

    procedure UpdateWindow()
    begin
        IF NOT GUIALLOWED THEN EXIT;
        gdlgWindow.UPDATE(1, gintToDo1);
        gdlgWindow.UPDATE(2, gintToDo2);
        gdlgWindow.UPDATE(3, gintFixed);
    end;

    procedure CloseWindow()
    begin
        IF NOT GUIALLOWED THEN EXIT;
        IF NOT gblnPrint THEN
            MESSAGE(STRSUBSTNO(
              'Prices With No End Date        %1\\' +
              'Price Records ''Closed''       %2\\' +
              'Remaining ''Open'' Price Records %3\\\\' +
              gtxtUpdateText,
              gintToDo2, gintFixed, gintToDo2 - gintFixed
            ));
        gdlgWindow.CLOSE;
    end;

    var
        grecBestIspcTEMP: Record "EN Sales Price";
        gintToDo1: Integer;
        gintDone1: Integer;
        gintToDo2: Integer;
        gintFixed: Integer;
        gdlgWindow: Dialog;
        gdatNewEndDate: Date;
        gblnFixed: Boolean;
        gtxtUpdateText: Text[80];
        gblnPrint: Boolean;
        gblnUpdateDB: Boolean;
        gblnPrintUnchanged: Boolean;
        grecIspcTEMP: Record "EN Sales Price";
}