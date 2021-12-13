report 14228852 "Close Purchase Prices ELA"
{
    Caption = 'Close Purchase Prices';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem("Purchase Price"; "Purchase Price")
        {
            DataItemTableView = SORTING("Item No.", "Purchase Type ELA", "Vendor No.", "Location Code ELA", "Starting Date", "Currency Code", "Variant Code", "Unit of Measure Code", "Minimum Quantity") ORDER(Ascending);
            RequestFilterFields = "Item No.", "Purchase Type ELA";
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
                grecIspcTEMP := "Purchase Price";
                IF grecIspcTEMP.INSERT THEN BEGIN
                    gintToDo2 += 1;
                END;
                UpdateWindow;
            end;
        }
        dataitem(Integer; Integer)
        {
            DataItemTableView = SORTING(Number) ORDER(Ascending);
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
            begin
                IF Number > 1 THEN
                    grecIspcTEMP.NEXT;

                WITH lrecPurchPrice DO BEGIN
                    gdatNewEndDate := 0D;
                    gblnFixed := FALSE;
                    RESET;
                    SETRANGE("Purchase Type ELA", grecIspcTEMP."Purchase Type ELA");
                    SETRANGE("Vendor No.", grecIspcTEMP."Vendor No.");
                    SETRANGE("Order Address Code ELA", grecIspcTEMP."Order Address Code ELA");
                    SETRANGE("Item No.", grecIspcTEMP."Item No.");
                    SETRANGE("Currency Code", grecIspcTEMP."Currency Code");
                    SETRANGE("Minimum Quantity", grecIspcTEMP."Minimum Quantity");
                    SETRANGE("Unit of Measure Code", grecIspcTEMP."Unit of Measure Code");
                    SETRANGE("Location Code ELA", grecIspcTEMP."Location Code ELA");
                    SETRANGE("Variant Code", grecIspcTEMP."Variant Code");
                    SETFILTER("Starting Date", '>%1', grecIspcTEMP."Starting Date");
                    SETFILTER("Ending Date", '%1', 0D);

                    IF FINDFIRST THEN BEGIN
                        CLEAR(grecBestIspcTEMP);
                        grecBestIspcTEMP."Starting Date" := 29991231D;
                        REPEAT
                            IF "Starting Date" < grecBestIspcTEMP."Starting Date" THEN
                                grecBestIspcTEMP := lrecPurchPrice;
                        UNTIL NEXT = 0;
                        // Did we find a record?
                        IF grecBestIspcTEMP."Starting Date" <> 29991231D THEN BEGIN
                            // Get the 'real' record we are trying to fix
                            RESET;
                            GET(
                                grecIspcTEMP."Item No.",
                                grecIspcTEMP."Purchase Type ELA",
                                grecIspcTEMP."Vendor No.",
                                grecIspcTEMP."Location Code ELA",
                                grecIspcTEMP."Starting Date",
                                grecIspcTEMP."Currency Code",
                                grecIspcTEMP."Variant Code",
                                grecIspcTEMP."Unit of Measure Code",
                                grecIspcTEMP."Minimum Quantity"
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
        gblnUpdateDB := TRUE;
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
        grecIspcTEMP: Record "Purchase Price";
        grecBestIspcTEMP: Record "Purchase Price";
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
}