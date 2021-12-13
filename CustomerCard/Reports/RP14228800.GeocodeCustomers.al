report 14228800 "Geocode Customers ELA"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;
/*
    dataset
    {
        dataitem(DataItemName; Customer)
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.";
            trigger OnPreDataItem()
            begin
                gdecErrorCount := 0;

                gintCount := COUNT;
                gintCounter := 0;

                gdlgWindow.OPEN(gtxt002);
            end;

            trigger OnAfterGetRecord()
            var
                lcduGeoMgmt: Codeunit "Geocoding Mgmt. ELA";
                ltxtError: Text[1024];
            begin
                gintCounter += 1;

                gdlgWindow.UPDATE(1, "No.");
                gdlgWindow.UPDATE(2, ROUND(gintCounter / gintCount) * 10000);

                //-- Only update what is necessary (let's assume nobody lives at latitude/longitude = 0)
                IF (Latitude = 0) OR (Longitude = 0) THEN BEGIN
                    ltxtError := lcduGeoMgmt.jfGeocodeCustomer(Customer);

                    IF ltxtError <> '' THEN BEGIN
                        IF gblnStopOnError THEN BEGIN
                            ERROR(gtxt000, "No.", ltxtError);

                            gdecErrorCount += 1;
                        END;
                    END;
                END;
            end;

            trigger OnPostDataItem()
            begin
                IF (gdecErrorCount <> 0) AND (GUIALLOWED) THEN
                    MESSAGE(gtxt001, gdecErrorCount);
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
                    field("Stop on Error"; gblnStopOnError)
                    {
                        ApplicationArea = All;

                    }
                }
            }
        }


    }

    var
        gblnStopOnError: Boolean;
        gdecErrorCount: Decimal;
        gintCount: Integer;
        gintCounter: Integer;
        gdlgWindow: Dialog;
        gtxt000: TextConst ENU = 'Customer No. %1: %2.';
        gtxt001: TextConst ENU = '%1 customers were not updated due to errors.';
        gtxt002: TextConst ENU = 'Processing Customer #1#########  @2@@@@@@@@@@';*/
}