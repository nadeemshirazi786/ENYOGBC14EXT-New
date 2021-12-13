table 51006 "DSD Route Stop Tmplt. Detail"
{
    fields
    {
        field(1; "Route Sequence Template Code"; Code[10])
        {
            TableRelation = "DSD Route Stop Template";
        }
        field(3; Route; Code[10])
        {
            TableRelation = Location;
        }
        field(5; Weekday; Enum Weekdays)
        {
        }
        field(10; "Line No."; Integer)
        {
        }
        field(15; "Customer No."; Code[20])
        {
            TableRelation = Customer;

            trigger OnValidate()
            begin
                jfGetCustomerData;
            end;
        }
        field(20; "Start Date"; Date)
        {
        }
        field(25; "End Date"; Date)
        {
        }
        field(70; "New Sequence"; Integer)
        {
        }
        field(200; "Customer Name"; Text[50])
        {
        }
        field(205; Address; Text[50])
        {
            Caption = 'Address';
        }
        field(206; "Address 2"; Text[50])
        {
            Caption = 'Address 2';
        }
        field(207; City; Text[30])
        {
            Caption = 'City';
            TableRelation = IF ("Country/Region Code" = CONST('')) "Post Code".City
            ELSE
            IF ("Country/Region Code" = FILTER(<> '')) "Post Code".City WHERE("Country/Region Code" = FIELD("Country/Region Code"));
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                PostCode.ValidateCity(City, "Post Code", County, "Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(211; "Post Code"; Code[20])
        {
            Caption = 'ZIP Code';
            TableRelation = IF ("Country/Region Code" = CONST('')) "Post Code"
            ELSE
            IF ("Country/Region Code" = FILTER(<> '')) "Post Code" WHERE("Country/Region Code" = FIELD("Country/Region Code"));
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                PostCode.ValidatePostCode(City, "Post Code", County, "Country/Region Code", (CurrFieldNo <> 0) and GuiAllowed);
            end;
        }
        field(212; County; Text[30])
        {
            Caption = 'State';
        }
        field(215; "Delivery Zone Code"; Code[20])
        {
            Description = 'JF4693MG   TBR';
            Editable = false;

            trigger OnValidate()
            begin

            end;
        }
        field(216; "Country/Region Code"; Code[10])
        {
            TableRelation = "Country/Region";
        }
        field(23019000; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            Description = 'JF09573AC';
            TableRelation = Location WHERE("Use As In-Transit" = CONST(false));

            trigger OnValidate()
            begin
                grecDSDSetup.Get;
                grecDSDSetup.TestField("Override Loc. from Route Temp.", false);
            end;
        }
        field(23019001; "Ship-to Code"; Code[10])
        {
            Caption = 'Ship-to Code';
            Description = 'JF09573AC';
            TableRelation = "Ship-to Address".Code WHERE("Customer No." = FIELD("Customer No."));

            trigger OnValidate()
            var
                ljfText030: Label '%1 %2 will be recalculated. Are you sure you want to change the %3?';
            begin
                jfGetCustomerData;
            end;
        }
    }

    keys
    {
        key(Key1; "Route Sequence Template Code", Weekday, Route, "Line No.")
        {
            Clustered = true;
        }
        key(Key2; Route, "Start Date", "End Date", "Line No.")
        {
        }
        key(Key3; "New Sequence")
        {
        }
        key(Key4; "Customer No.", "Start Date", "End Date", Weekday)
        {
        }
        key(Key5; "Customer No.", "Location Code", "Ship-to Code")
        {
        }
    }
    trigger OnInsert()
    begin
        TestField(Route);
        TestField("Customer No.");
        TestField(Weekday);

        CheckForCustomerRedundancy;

        lrecRouteTemplate.Get("Route Sequence Template Code");
        "Start Date" := lrecRouteTemplate."Start Date";
        "End Date" := lrecRouteTemplate."End Date";
    end;

    trigger OnModify()
    begin
        CheckForCustomerRedundancy;
    end;

    var
        jfText030: Label '%1 is already on %2';
        PostCode: Record "Post Code";
        grecDSDSetup: Record "DSD Setup";
        lrecRouteTemplate: Record "DSD Route Stop Template";

    local procedure CheckForCustomerRedundancy()
    var
        lrecRouteTemplateDetail: Record "DSD Route Stop Tmplt. Detail";
        ltxtContext: Text[256];
    begin
        ltxtContext := FieldCaption("Customer No.") + ' ' + "Customer No.";
        if "Location Code" <> '' then begin
            ltxtContext := ltxtContext + ', ' + FieldCaption("Location Code") + ' ' + "Location Code";
        end;
        if "Ship-to Code" <> '' then begin
            ltxtContext := ltxtContext + ', ' + FieldCaption("Ship-to Code") + ' ' + "Ship-to Code";
        end;

        lrecRouteTemplateDetail.SetCurrentKey("Route Sequence Template Code",
                                              Weekday, Route, "Line No.");
        lrecRouteTemplateDetail.SetRange("Route Sequence Template Code", "Route Sequence Template Code");
        lrecRouteTemplateDetail.SetRange(Weekday, Weekday);
        lrecRouteTemplateDetail.SetFilter(Route, '<>%1', Route);
        lrecRouteTemplateDetail.SetRange("Line No.");

        lrecRouteTemplateDetail.SetRange("Customer No.", "Customer No.");
        lrecRouteTemplateDetail.SetFilter("Location Code", '=%1', "Location Code");
        lrecRouteTemplateDetail.SetFilter("Ship-to Code", '=%1', "Ship-to Code");

        if lrecRouteTemplateDetail.FindFirst then begin
            Error(jfText030, ltxtContext, lrecRouteTemplateDetail.Route);
        end;


        lrecRouteTemplateDetail.Reset;
        lrecRouteTemplateDetail.SetCurrentKey("Route Sequence Template Code",
                                              Weekday, Route, "Line No.");
        lrecRouteTemplateDetail.SetRange("Route Sequence Template Code", "Route Sequence Template Code");
        lrecRouteTemplateDetail.SetRange(Weekday, Weekday);
        lrecRouteTemplateDetail.SetRange(Route, Route);
        lrecRouteTemplateDetail.SetFilter("Line No.", '<>%1', "Line No.");

        lrecRouteTemplateDetail.SetRange("Customer No.", "Customer No.");
        lrecRouteTemplateDetail.SetFilter("Location Code", '=%1', "Location Code");
        lrecRouteTemplateDetail.SetFilter("Ship-to Code", '=%1', "Ship-to Code");

        if lrecRouteTemplateDetail.FindFirst then begin
            Error(jfText030, ltxtContext, lrecRouteTemplateDetail.Route);
        end;

    end;

    [Scope('Internal')]
    procedure jfGetCustomerData()
    var
        lrecCust: Record Customer;
        lrecShipTo: Record "Ship-to Address";
    begin
        if lrecShipTo.Get("Customer No.", "Ship-to Code") then begin
            "Customer Name" := lrecShipTo.Name;

            Address := lrecShipTo.Address;
            "Address 2" := lrecShipTo."Address 2";
            City := lrecShipTo.City;
            "Post Code" := lrecShipTo."Post Code";
            County := lrecShipTo.County;
            "Country/Region Code" := lrecShipTo."Country/Region Code";
        end else
            if lrecCust.Get("Customer No.") then begin
                "Customer Name" := lrecCust.Name;

                Address := lrecCust.Address;
                "Address 2" := lrecCust."Address 2";
                City := lrecCust.City;
                "Post Code" := lrecCust."Post Code";
                County := lrecCust.County;
                "Country/Region Code" := lrecCust."Country/Region Code";
            end else begin
                jfClearCustomerData;
            end;
    end;

    [Scope('Internal')]
    procedure jfClearCustomerData()
    begin
        Clear("Customer Name");
        Clear(Address);
        Clear("Address 2");
        Clear(City);
        Clear("Post Code");
        Clear(County);
        Clear("Country/Region Code");
        Clear("Delivery Zone Code");
    end;
}

