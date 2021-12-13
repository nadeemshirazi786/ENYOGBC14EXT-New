page 14229600 "Workwave Manifest List ELA"
{
    Caption = 'Workwave Manifest List';
    InsertAllowed = false;
    PageType = Worksheet;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "Workwave Manifest ELA";
    SourceTableView = SORTING("No.") ORDER(Ascending) WHERE("No." = FILTER(<> ''));

    layout
    {
        area(content)
        {
            field("Shipment Date Filter"; ShipDateFilter)
            {

                trigger OnValidate()
                begin
                    // AppMgt.MakeDateFilter(ShipDateFilter);
                    Rec.SETFILTER("Shipment Date", ShipDateFilter);
                    CurrPage.UPDATE;
                end;
            }
            field("Driver Code Filter"; DriverCodeFilter)
            {

                trigger OnValidate()
                begin
                    Rec.SETFILTER("Driver Code", DriverCodeFilter);
                    CurrPage.UPDATE;
                end;
            }
            field("Truck Code Filter"; TruckCodeFilter)
            {

                trigger OnValidate()
                begin
                    Rec.SETFILTER("Truck Code", TruckCodeFilter);
                    CurrPage.UPDATE;
                end;
            }
            field("Sales Order Filter"; SaleNoFilter)
            {

                trigger OnValidate()
                begin
                    Rec.SETFILTER("Order No.", SaleNoFilter);
                    CurrPage.UPDATE;
                end;
            }
            repeater(Group)
            {
                field("No."; "No.")
                {
                    Editable = false;
                }
                field("Sell-To Customer No."; "Sell-To Customer No.")
                {
                    Editable = false;
                }
                field("Order No."; "Order No.")
                {
                    Editable = false;
                }
                field("Shipment Date"; "Shipment Date")
                {
                    Editable = false;
                }
                field(Departured; Departured)
                {
                }
                field("Dropoff Service Time"; "Dropoff Service Time")
                {
                }
                field("Dropoff Full Address"; "Dropoff Full Address")
                {
                }
                field("Dropoff Street"; "Dropoff Street")
                {
                }
                field("Droppoff City"; "Droppoff City")
                {
                }
                field("Dropoff State"; "Dropoff State")
                {
                }
                field("Dropoff Zip"; "Dropoff Zip")
                {
                }
                field("Dropoff Country"; "Dropoff Country")
                {
                }
                field(Eligibilty; Eligibilty)
                {
                }
                field("Dropoff Time Window Start"; "Dropoff Time Window Start")
                {
                }
                field("Dropoff Time Window End"; "Dropoff Time Window End")
                {
                }
                field("Dropoff Time Window Start 2"; "Dropoff Time Window Start 2")
                {
                }
                field("Dropoff Time Window End 2"; "Dropoff Time Window End 2")
                {
                }
                field(Load; Load)
                {
                }
                field("Service Time"; "Service Time")
                {

                }
                field("Required vehicle"; "Required vehicle")
                {
                }
                field("Dropoff Required Tag"; "Dropoff Required Tag")
                {
                }
                field("Dropoff Banned Tags"; "Dropoff Banned Tags")
                {
                }
                field("Dropoff Latitude"; "Dropoff Latitude")
                {
                }
                field("Dropoff Longitude"; "Dropoff Longitude")
                {
                }
                field(Quantity; Quantity)
                {
                    Editable = false;
                }
                field("Sent to workwave"; "Sent to workwave")
                {
                }
                field("Route No."; "Route No.")
                {
                    Editable = false;
                }
                field("Truck Code"; "Truck Code")
                {
                    Editable = false;
                }
                field("Driver Code"; "Driver Code")
                {
                    Editable = false;
                }
                field("Customer No."; "Customer No.")
                {
                    Editable = false;
                }
                field("WW UUID"; "WW UUID")
                {
                    Editable = false;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Export to Workwave")
            {
                Caption = 'Export to Workwave';
                Image = Document;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    WWManRec.COPYFILTERS(Rec);
                    WWManRec.SETRANGE("Sent to workwave", FALSE);
                    ExportOrderstoWW(WWManRec);
                end;
            }
            action("Update from Workwave")
            {
                Caption = 'Update from Workwave';
                Image = Document;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    jsonmanagement: Codeunit "JSON Management";
                    "jsonarray": JsonArray;
                    jobject: JsonObject;
                    arraystring: Text;
                    myfile: File;
                    streamintest: InStream;
                    buffer: Text;
                    RespTxt: Text;
                    i: Integer;
                    JSonResponse: JsonObject;
                    LocObj: JsonObject;
                    TimeObj: JsonObject;
                    val: JsonValue;
                    responsestream: InStream;
                    responsebuffer: BigText;
                    Cust: Record Customer;
                    jobject1: JsonObject;
                    jobject2: JsonObject;
                    Resource: Record Resource;
                begin
                    ImportfromWW;
                end;
            }
            action(Reload)
            {
                Caption = 'Reload';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    PopulateData();
                    CurrPage.UPDATE;
                end;
            }
            action("Sales Order")
            {
                Image = document;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    SalesOrderPage: Page "Sales Order";
                    SalesRec: Record "Sales Header";
                    WWman: Record "Workwave Manifest ELA";
                begin
                    CurrPage.SETSELECTIONFILTER(WWman);
                    IF WWman.COUNT = 1 THEN BEGIN
                        IF WWman.FINDSET THEN;
                        IF SalesRec.GET(SalesRec."Document Type"::Order, WWman."No.") THEN BEGIN
                            SalesOrderPage.SETRECORD(SalesRec);
                            SalesOrderPage.RUNMODAL();
                        END;
                    END;
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        PopulateData;
        CurrPage.UPDATE;
    end;

    var
        SalesHeader: Record "Sales Header";
        Location: Record Location;
        WWMan: Record "Workwave Manifest ELA";
        Customer: Record Customer;
        [InDataSet]
        ShipDateFilter: Text;
        RouteNoFilter: Code[20];
        DriverCodeFilter: Code[20];
        TruckCodeFilter: Code[20];
        WWManRec: Record "Workwave Manifest ELA";
        dec: Decimal;
        dur: Integer;
        k: JsonObject;
        SalesLine: Record "Sales Line";
        CustNoFilter: Code[20];
        SaleNoFilter: Code[20];
        SalesOrderFilter: Code[20];
        WorkWaveSetup: Record "Workwave Setup ELA";


    procedure PopulateData()
    var
        int: Decimal;
    begin
        SalesHeader.RESET;
        SalesHeader.SETRANGE(SalesHeader."Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SETFILTER("Shipment Method Code", '<>%1', 'PICKUP');
        SalesHeader.SETFILTER("Order Template Location ELA", '<>%1', 'B*');
        IF SalesHeader.FINDSET THEN
            REPEAT
                IF Location.GET(SalesHeader."Location Code") THEN BEGIN
                    //IF Location."Enabled for workwave" = TRUE THEN BEGIN
                    IF NOT WWMan.GET(SalesHeader."No.") THEN BEGIN
                        WWMan.INIT;
                        WWMan."No." := SalesHeader."No.";
                        WWMan.Load := SalesHeader."No. Pallets";
                        WorkWaveSetup.Get();
                        WWMan."Service Time" := WorkWaveSetup."Service Time" * WWMan.Load;
                        WWMan."Sell-To Customer No." := SalesHeader."Sell-to Customer No.";
                        WWMan."Order No." := WWMan."No.";
                        WWMan."Shipment Date" := SalesHeader."Shipment Date";
                        //WWMan."Dropoff Full Address" := SalesHeader."Ship-to Address";
                        WWMan."Dropoff Street" := SalesHeader."Ship-to Address";
                        WWMan."Droppoff City" := SalesHeader."Ship-to City";
                        WWMan."Dropoff State" := SalesHeader."Ship-to County";
                        WWMan."Dropoff Zip" := SalesHeader."Ship-to Post Code";
                        WWMan."Dropoff Country" := SalesHeader."Ship-to Country/Region Code";
                        WWMan."Dropoff Full Address" := SalesHeader."Ship-to Address" +
                       SalesHeader."Ship-to City" + ',' + WWMan."Dropoff State" + ',' + SalesHeader."Ship-to Country/Region Code";
                        IF Customer.GET(SalesHeader."Sell-to Customer No.") THEN BEGIN
                            WWMan."Dropoff Longitude" := Customer."Longitude ELA";
                            WWMan."Dropoff Latitude" := Customer."Latitude ELA";
                            WWMan."Dropoff Time Window Start" := Customer."Dropoff Time Window Start ELA";
                            WWMan."Dropoff Time Window End" := Customer."Dropoff Time Window End ELA";
                            WWMan."Dropoff Time Window Start 2" := Customer."Dropoff Time Window Start 2 ELA";
                            WWMan."Dropoff Time Window End 2" := Customer."Dropoff Time Window End 2 ELA";
                            WWMan."Required vehicle" := Customer."Required Vehicle ELA";
                            WWMan."Dropoff Required Tag" := Customer."Dropoff Required Tags ELA";
                            WWMan."Dropoff Banned Tags" := Customer."Dropoff Banned Tags ELA";
                            WWMan."Customer No." := Customer."No.";
                        END;
                        WWMan."Dropoff Service Time" := 30;
                        SalesLine.RESET;
                        SalesLine.SETRANGE(SalesLine."Document No.", SalesHeader."No.");
                        IF SalesLine.FINDSET THEN
                            SalesLine.CALCSUMS(Quantity);
                        WWMan.Quantity := SalesLine.Quantity;
                        WWMan.INSERT;
                    END;
                    // END;
                END;
            UNTIL SalesHeader.NEXT = 0;
        ShipDateFilter := FORMAT(TODAY);
        Rec.SETRANGE("Shipment Date", TODAY);
        Rec.SETFILTER("Sell-To Customer No.", CustNoFilter);
        Rec.SETFILTER("No.", SaleNoFilter);
        CurrPage.UPDATE;
    end;

    procedure ExportOrderstoWW(var WWRec: Record "Workwave Manifest ELA")
    var
        jsonmanagement: Codeunit "JSON Management";
        "jsonarray": JsonArray;
        jobject: JsonObject;
        a: Text;
        i: Integer;
        RequestContent: HttpContent;
        RequestHeader: HttpHeaders;
        Http: HttpClient;
        response: HttpResponseMessage;
        result: Text;
        Request: HttpRequestMessage;
        JSonResponse: JsonObject;
        JsonTextWriter: JsonObject;
        JsonText: OutStream;
        Token: JsonToken;
        TokArray: JsonArray;
        TokObject: JsonObject;
        JsToken: JsonToken;
        Data: Text;
        LocObj: JsonObject;
        TimeObj: JsonObject;
        val: JsonValue;
        JArray: JsonArray;
        responsestream: InStream;
        Cust: Record Customer;
        jobject1: JsonObject;
        jobject2: JsonObject;
        resource: Record Resource;
        Aarray: JsonArray;
        OArray: JsonArray;
        TArray: JsonArray;
        TObject: JsonObject;
        TagsInArray: JsonArray;
        TagsOutArray: JsonArray;
        CusObj: JsonObject;
        JsObject: JsonObject;
        Jobject5: JsonObject;
        jIdToken: JsonToken;
        NewObj: JsonObject;
        ResponceText: Text;
        cus: Record Customer;
        int: Integer;
        txt: Text;
        txt2: Text;
        int2: Integer;
        tt: List of [Text];
        ii: Integer;
        id: Code[50];
        id2: code[50];
        id3: code[50];
        JsonObj: JsonObject;
        JsObj: JsonObject;
        JsoToken: JsonToken;
        NewToken: JsonToken;
        Token1: JsonToken;

    begin
        if WWRec.FindSet() then
            repeat
                Clear(RequestContent);
                Clear(Request);
                Clear(RequestHeader);
                Clear(Http);
                Clear(JsObject);
                Clear(JsonTextWriter);
                Clear(jobject);
                Clear(jobject1);
                Clear(jobject2);
                Clear(CusObj);
                Clear(LocObj);
                Clear(TimeObj);
                Clear(TObject);
                Clear(jsonarray);
                Clear(TArray);
                Clear(TagsInArray);
                Clear(TagsOutArray);
                Clear(Aarray);
                Clear(OArray);
                Clear(val);
                Clear(JArray);
                Clear(NewObj);
                Clear(ResponceText);
                JsonTextWriter.Add('name', WWRec."No.");
                JsonTextWriter.Add('eligibility', jobject);
                jobject.Add('type', 'on');
                jobject.Add('onDates', JArray);
                JArray.Add(Format(WWRec."Shipment Date", 0, '<Year4><Month,2><Day,2>'));
                //JArray.Add('20210804');
                "jsonarray".Add(JsonTextWriter);
                //Aarray.Add(jobject);
                if resource.Get(WWRec."Required vehicle") then
                    JsonTextWriter.Add('forceVehicleId', resource."Workwave Resource UUID ELA")
                else
                    JsonTextWriter.Add('forceVehicleId', val);
                if Cust.get(WWRec."Sell-To Customer No.") then
                    JsonTextWriter.Add('priority', Cust.Priority);
                JsonTextWriter.Add('loads', jobject1);
                jobject1.Add('pallets', Format(WWRec.Load * 100));
                JsonTextWriter.Add('pickup', val);
                JsonTextWriter.Add('delivery', jobject2);
                jobject2.Add('depotId', val);
                jobject2.Add('location', LocObj);
                LocObj.Add('address', WWRec."Dropoff Full Address");
                LocObj.Add('latLng', OArray);
                txt := (FORMAT(WWRec."Dropoff Latitude" * 10000000, 8, 1));
                Evaluate(int, txt);
                OArray.Add(int);
                txt2 := (Format(WWRec."Dropoff Longitude" * 10000000, 9, 1));
                Evaluate(int2, txt2);
                OArray.Add(int2);
                //OArray.Add(FORMAT(WWRec."Dropoff Latitude" * 10000000, 8, 1));
                // OArray.Add(Format(WWRec."Dropoff Longitude" * 10000000, 9, 1));
                //OArray.Add(42490347);
                //OArray.Add(-71091119);
                LocObj.Add('status', 'OK');
                LocObj.Add('geoAddress', '');
                jobject2.Add('timeWindows', TArray);
                TArray.Add(TimeObj);

                IF WWRec."Dropoff Time Window Start" <> 0T THEN BEGIN
                    dur := WWRec."Dropoff Time Window Start" - 000000T;
                END;
                TimeObj.Add('startSec', dur DIV 1000);
                IF WWRec."Dropoff Time Window End" <> 0T THEN BEGIN
                    dur := WWRec."Dropoff Time Window End" - 000000T;
                    TimeObj.Add('endSec', dur DIV 1000)
                END ELSE begin
                    TimeObj.Add('endSec', 86340)
                end;
                TArray.Add(TObject);
                IF WWRec."Dropoff Time Window Start 2" <> 0T THEN BEGIN
                    dur := WWRec."Dropoff Time Window Start 2" - 000000T;
                    TObject.Add('startSec', dur DIV 1000);
                end;

                IF WWRec."Dropoff Time Window End 2" <> 0T THEN BEGIN
                    dur := WWRec."Dropoff Time Window End 2" - 000000T;
                    TObject.Add('endSec', dur DIV 1000)
                END ELSE begin
                    TObject.Add('endSec', 86340);
                end;
                jobject2.Add('notes', 'demonstrate the concept of multiple time windows as well as eligibility date range');
                jobject2.Add('serviceTimeSec', Format(WWRec."Service Time" * 60));
                IF WWRec."Dropoff Required Tag" <> '' THEN
                    JsonTextWriter.Add('', WWRec."Dropoff Required Tag");
                jobject2.Add('tagsIn', TagsInArray);

                IF WWRec."Dropoff Banned Tags" <> '' THEN
                    JsonTextWriter.Add('', WWRec."Dropoff Banned Tags");
                jobject2.Add('tagsOut', TagsOutArray);
                jobject2.Add('customFields', CusObj);
                CusObj.Add('CustomerNo', WWRec."Customer No.");
                CusObj.Add('OrderId', WWRec."Order No.");
                JsonTextWriter.Add('Service', false);
                JsObject.Add('orders', jsonarray);
                Message(Format(JsObject));
                WorkWaveSetup.GET();
                RequestContent.WriteFrom(format(jsobject));
                RequestContent.GetHeaders(RequestHeader);
                RequestHeader.Remove('Content-Type');
                RequestHeader.Add('Content-Type', 'application/json');
                RequestHeader.Add('X-WorkWave-Key', WorkWaveSetup."API Key");
                Request.Content := RequestContent;
                Request.SetRequestUri(WorkWaveSetup."Base URL" + '/' + WorkWaveSetup."Territory API" + '/' + WorkWaveSetup."Territory Id" + '/' + WorkWaveSetup."Order API");
                Request.Method := 'POST';
                Http.Send(Request, response);
                a := FORMAT(response.HttpStatusCode);
                IF UPPERCASE(a) = '200' THEN BEGIN
                    WWRec."Sent to workwave" := TRUE;
                    WWRec.MODIFY(TRUE);
                END;
            UNTIL WWRec.NEXT = 0;

        SLEEP(2000);
        Clear(Request);
        Clear(RequestContent);
        Clear(RequestHeader);
        Clear(Http);
        Clear(response);
        Clear(Data);
        WorkWaveSetup.GET();
        RequestContent.Clear();
        Request.GetHeaders(RequestHeader);
        RequestHeader.Add('X-WorkWave-Key', WorkWaveSetup."API Key");
        Request.SetRequestUri(WorkWaveSetup."Base URL" + '/' + WorkWaveSetup."Territory API" + '/' + WorkWaveSetup."Territory Id" + '/' + WorkWaveSetup."Order API");
        HTTP.Send(Request, response);
        a := FORMAT(response.HttpStatusCode);
        response.Content.ReadAs(Data);
        Message(Data);
        NewObj.ReadFrom(Data);
        NewObj.Get('orders', Token);
        NewObj := Token.AsObject();
        tt := NewObj.Keys;
        // Message(Format(tt.Count));
        // Message(Format(tt));
        for ii := 1 to tt.Count do begin
            NewObj.Get(tt.Get(ii), Token);
            Token.SelectToken('delivery', jIdToken);
            JsonObj := jIdToken.AsObject();
            JsonObj.SelectToken('customFields', JsoToken);
            //Message(Format(JsoToken));
            // JsonObj:=JsoToken.AsObject();
            JsoToken.SelectToken('OrderId', Token1);
            Id := Token1.AsValue().AsCode();
            WWMan.Reset();
            WWMan.SetRange("No.", id);
            if WWMAN.FindFirst() then begin
                Token.SelectToken('id', JsToken);
                WWMan."WW UUID" := JsToken.AsValue().AsText();
                WWMan.Modify(true);
            end;
        end;
    end;

    procedure ImportfromWW()
    var
        jsonmanagement: Codeunit "JSON Management";
        "jsonarray": JsonArray;
        jobject: JsonObject;
        arraystring: Text;
        RespTxt: Text;
        i: Integer;
        RequestContent: HttpContent;
        RequestHeader: HttpHeaders;
        Http: HttpClient;
        response: HttpResponseMessage;
        jIdToken: JsonToken;
        NToken: JsonToken;
        NoToken: JsonToken;
        IdToken: JsonToken;
        result: Text;
        result2: Text;
        VechileObj: JsonObject;
        VechileObj2: JsonObject;
        VechileToken: JsonToken;
        VechileExternalId: JsonToken;
        VechileExternalId2: JsonToken;
        VechileUUId: JsonToken;
        a: Text;
        Request: HttpRequestMessage;
        JSonResponse: JsonObject;
        JsonTextWriter: JsonObject;
        Token: JsonToken;
        LocObj: JsonObject;
        TimeObj: JsonObject;
        val: JsonValue;
        WWToken: JsonToken;
        responsestream: InStream;
        responsebuffer: BigText;
        Cust: Record Customer;
        jobject1: JsonObject;
        jobject2: JsonObject;
        Resource: Record Resource;
        RouteId: Text;
        VehicleId: Text;
        DriverId: Text;
        VehicleResource: Record Resource;
        DriverResource: Record Resource;
        WWRec: Record "Workwave Manifest ELA";
        tt: List of [Text];
        tt2: List of [Text];
        tt3: List of [Text];
        tt4: List of [Text];
        ii: Integer;
        ii2: Integer;
        ii3: Integer;
        ii4: Integer;
        id: code[50];
        id4: code[50];
        DateV: Date;
        TestObj: JsonObject;
        Robject: JsonObject;
        Robject2: JsonObject;
        RToken: JsonToken;
        RToken2: JsonToken;
        RToken3: JsonToken;
        RToken4: JsonToken;
        RToken5: JsonToken;
        RToken6: JsonToken;
        RToken7: JsonToken;
        RToken8: JsonToken;

    begin
        Clear(Request);
        Clear(RequestContent);
        Clear(RequestHeader);
        Clear(result);
        Clear(a);
        Clear(Http);

        WorkWaveSetup.GET();
        Request.GetHeaders(RequestHeader);
        RequestHeader.Add('X-WorkWave-Key', WorkWaveSetup."API Key");
        Request.SetRequestUri(WorkWaveSetup."Base URL" + '/' + WorkWaveSetup."Territory API" + '/' + WorkWaveSetup."Territory Id" + '/' + WorkWaveSetup."Driver API");
        HTTP.Send(Request, response);
        a := FORMAT(response.HttpStatusCode);
        response.Content.ReadAs(result);
        jobject.ReadFrom(result);
        jobject.Get('drivers', Token);
        jobject := Token.AsObject();
        tt := jobject.Keys;
        //Message(Format(jobject));
        for ii := 1 to tt.Count do begin
            jobject.Get(tt.Get(ii), Token);
            Token.SelectToken('name', jIdToken);
            id := jIdToken.AsValue().AsCode();
            Resource.SetRange("No.", id);
            if not Resource.FindSet() then begin
                Resource.Reset();
                Resource.Init();
                Token.SelectToken('name', NoToken);
                Resource."No." := NoToken.AsValue().AsCode();
                Token.SelectToken('name', NToken);
                Resource.Name := NToken.AsValue().AsText();
                Resource.Type := Resource.Type::Person;
                Token.SelectToken('id', IdToken);
                Resource."Workwave Resource UUID ELA" := IdToken.AsValue().AsCode();
                Resource.Insert();
            end;
        end;
        Clear(Request);
        Clear(RequestContent);
        Clear(RequestHeader);
        Clear(result);
        Clear(a);
        Clear(Http);
        Clear(id);
        WorkWaveSetup.GET();
        Request.GetHeaders(RequestHeader);
        RequestHeader.Add('X-WorkWave-Key', WorkWaveSetup."API Key");
        Request.SetRequestUri(WorkWaveSetup."Base URL" + '/' + WorkWaveSetup."Territory API" + '/' + WorkWaveSetup."Territory Id" + '/' + WorkWaveSetup."Vehicle ApI");
        HTTP.Send(Request, response);
        a := FORMAT(response.HttpStatusCode);
        response.Content.ReadAs(result);
        VechileObj.ReadFrom(result);
        // Message(Format(result));
        VechileObj.Get('vehicles', VechileToken);
        VechileObj := VechileToken.AsObject();
        tt2 := VechileObj.Keys;
        for ii2 := 1 to tt2.Count do begin
            VechileObj.Get(tt2.Get(ii2), Token);
            Token.SelectToken('externalId', VechileToken);
            id := VechileToken.AsValue().AsCode();
            Resource.SetRange("No.", id);
            if not Resource.FindFirst() then begin
                Resource.Reset();
                Resource.Init();
                Token.SelectToken('externalId', VechileExternalId);
                Resource."No." := VechileExternalId.AsValue().AsCode();
                Token.SelectToken('externalId', VechileExternalId2);
                Resource.Name := VechileExternalId2.AsValue().AsCode();
                Resource.Type := Resource.Type::Machine;
                Token.SelectToken('id', VechileUUId);
                Resource."Workwave Resource UUID ELA" := VechileUUId.AsValue().AsCode();
                Resource.Insert();
            end
        end;
        Clear(Request);
        Clear(RequestContent);
        Clear(RequestHeader);
        Clear(result);
        Clear(a);
        Clear(Http);
        WorkWaveSetup.GET();
        Request.GetHeaders(RequestHeader);
        RequestHeader.Add('X-WorkWave-Key', WorkWaveSetup."API Key");
        Request.SetRequestUri(WorkWaveSetup."Base URL" + '/' + WorkWaveSetup."Territory API" + '/' + WorkWaveSetup."Territory Id" + '/' + WorkWaveSetup."Route API");
        HTTP.Send(Request, response);
        a := FORMAT(response.HttpStatusCode);
        response.Content.ReadAs(result);
        Robject.ReadFrom(result);
        //Message(Format(result));
        Robject.SelectToken('routes', RToken);
        Robject := RToken.AsObject();
        //Message(Format(Robject));
        tt3 := Robject.Keys;
        for ii3 := 1 to tt3.Count do begin
            Robject.Get(tt3.Get(ii3), RToken2);
            Robject := RToken2.AsObject();
            //Message(Format(RToken2));
            RouteId := Format(Robject.SelectToken('id', RToken3));
            VehicleId := Format(Robject.SelectToken('vehicleId', RToken4));
            RouteId := Format(Robject.SelectToken('driverId', RToken5));
            Robject.SelectToken('steps', RToken5);
            Message(Format(RToken5));
            "jsonarray" := RToken5.AsArray();
            // Robject2 := RToken5.AsObject();
            //Message(Format(jsonarray.Count));
            for ii4 := 1 to "jsonarray".Count do begin
                "jsonarray".Get(ii4, RToken6);
                Robject2 := RToken6.AsObject();
                Robject2.SelectToken('orderId', RToken7);
                Message(Format(RToken7));
                id4 := RToken7.AsValue().AsCode();
                WWMan.Reset();
                WWMan.SetFilter(WWMan."WW UUID", id4);
                IF WWMan.FINDFIRST THEN BEGIN
                    VehicleResource.RESET;
                    VehicleResource.SETFILTER("Workwave Resource UUID ELA", VehicleId);
                    VehicleResource.SETRANGE(Type, VehicleResource.Type::Machine);
                    IF VehicleResource.FINDFIRST THEN BEGIN
                        WWMan."Truck Code" := VehicleResource."No.";
                    END;
                    DriverResource.RESET;
                    DriverResource.SETFILTER("Workwave Resource UUID ELA", DriverId);
                    DriverResource.SETRANGE(Type, DriverResource.Type::Person);
                    IF DriverResource.FINDFIRST THEN BEGIN
                        WWMan."Driver Code" := DriverResource."No.";
                    END;
                    Robject2.SelectToken('date', RToken8);
                    DateV := RToken8.AsValue().AsDate();
                    WWMan."Route No." := WWMan."Truck Code" + '-' + FORMAT(DateV);
                    WWMan.MODIFY;
                    IF SalesHeader.GET(SalesHeader."Document Type"::Order, WWMan."No.") THEN BEGIN
                        SalesHeader."Logistics Route No. ELA" := WWMan."Route No.";
                        SalesHeader."Inquiry Tracking No. ELA" := WWMan."Driver Code";
                        SalesHeader."Order Template Location ELA" := WWMan."Truck Code";
                        SalesHeader.MODIFY;
                    END;
                END;
            END;
        END;
    END;


    procedure CustFilter(CustNo: Code[20])
    begin
        CustNoFilter := CustNo;
    end;

    procedure SalesFilter(CustNo: Code[20])
    begin
        SaleNoFilter := CustNo;
    end;

}

