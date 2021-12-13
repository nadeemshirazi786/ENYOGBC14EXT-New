codeunit 14228800 "Geocoding Mgmt. ELA"
{
    trigger OnRun()
    begin

    end;

    /*procedure jfGeocodeCustomer(VAR precCustomer: Record Customer) ltxtError: Text[1024]
    var
        lautNavMaps: Automation;
        ltxtQuery: Text[250];
        lrecCountry: Record "Country/Region";
        ltxt000: TextConst ENU = 'The %1 is invalid.';
    begin
        ltxtError := '';

        //-- Create client-side automation object
        CREATE(lautNavMaps, TRUE, TRUE);

        IF lrecCountry.GET(precCustomer."Country/Region Code") THEN BEGIN
            ltxtQuery := precCustomer.Address + ', ' + precCustomer."Address 2" + ', ' +
                         precCustomer.City + ', ' + ', ' + precCustomer."Post Code" + ', ' + lrecCountry.Name;

            ltxtError := lautNavMaps.GetLocation(ltxtQuery, 2, precCustomer.Latitude, precCustomer.Longitude);

            IF ltxtError = '' THEN BEGIN
                precCustomer.MODIFY;
            END ELSE BEGIN
                ltxtQuery := precCustomer.City + ', ' + lrecCountry.Name;

                ltxtError := lautNavMaps.GetLocation(ltxtQuery, 0, precCustomer.Latitude, precCustomer.Longitude);

                IF ltxtError = '' THEN BEGIN
                    precCustomer.MODIFY;
                END;
            END;
        END ELSE BEGIN
            ltxtError := STRSUBSTNO(ltxt000, precCustomer.FIELDCAPTION("Country/Region Code"));
        END;
    end;

    procedure jfGetCustWithin(pdecLatitude1: Decimal; pdecLatitude2: Decimal; pdecLongitude1: Decimal; pdecLongitude2: Decimal; VAR pxmlResult: XMLport "Customer Geocode")
    var
        lrecCustomer: Record Customer;
    begin
        lrecCustomer.SETRANGE(Latitude, pdecLatitude1, pdecLatitude2);
        lrecCustomer.SETRANGE(Longitude, pdecLongitude1, pdecLongitude2);
        pxmlResult.SETTABLEVIEW(lrecCustomer);
    end;
*/
    var
        myInt: Integer;
}