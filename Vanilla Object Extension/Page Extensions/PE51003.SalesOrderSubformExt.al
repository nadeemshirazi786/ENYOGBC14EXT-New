pageextension 51003 "Sales Order Subform Ext" extends "Sales Order Subform"
{
    layout
    {
        addafter("Line No.")
        {
            field("Sales Price Exists"; PriceExists)
            {

            }
            field("Delivered Unit Price"; gdecDeliveredPrice)
            {

            }
            field("Lock Pricing"; "Lock Pricing ELA")
            {

            }
            field("Sales App Price"; "Sales App Price ELA")
            {
                Editable = false;
            }
            field("Original Order Qty. ELA"; "Original Order Qty. ELA")
            {
                ApplicationArea = All;
            }
            field("UOM Size Code"; isGetUomSizeCode)
            {

            }
            field("Unit Price Protection Level"; "Unit Price Prot Level ELA")
            {

            }
            field("Sales Price Source"; "Sales Price Source ELA")
            {
                Editable = false;
            }

        }
        addlast(Control1)
        {
            field("Green Quantity"; "Green Quantity")
            {
                ApplicationArea = All;
            }
            field("Green Tracking No."; "Green Tracking No.")
            {
                ApplicationArea = All;
            }
            field("Breaking Quantity"; "Breaking Quantity")
            {
                ApplicationArea = All;
            }
            field("Breaking Tracking No."; "Breaking Tracking No.")
            {
                ApplicationArea = All;
            }
            field("No Gas Quantity"; "No Gas Quantity")
            {
                ApplicationArea = All;
            }
            field("No Gas Tracking No."; "No Gas Tracking No.")
            {
                ApplicationArea = All;
            }
            field("Color Quantity"; "Color Quantity")
            {
                ApplicationArea = All;
            }
            field("Color Tracking No."; "Color Tracking No.")
            {
                ApplicationArea = All;
            }
            field(TrackingStatus; TrackingStatus)
            {
                Caption = 'Tracking Status';
                Editable = false;
                ApplicationArea = All;
            }
            field("Bottle Deposit Amount"; GetBottleAmount(Rec))
            {
                ApplicationArea = All;
            }
            field(FreightAmount; FreightAmount('S-Freight'))
            {
                Caption = 'Freight Amount';
            }
            field("Bottle Deposit"; "Bottle Deposit")
            {
                ApplicationArea = All;
            }
        }
    }
    trigger OnAfterGetRecord()
    var
        lblnItemTracking: Boolean;
        ldecPct: Decimal;
    begin
        CalcDeliveredPrice(gdecDeliveredPrice);
        SetStatus();

        ldecPct := ROUND(doTrackingExistsELA("Quantity (Base)", lblnItemTracking));
        TrackingStatus := UpdateTrackingStatus(ldecPct, lblnItemTracking);
        StyleTxt := SetStyle(ldecPct, lblnItemTracking);
    end;

    trigger OnOpenPage()
    begin
        SETFILTER(Type, '%1', Type::Item);
    end;


    trigger OnAfterGetCurrRecord()
    begin
        SetStatus();
    end;

    procedure isGetUomSizeCode(): Code[10]
    var
        lItemUOM: Record "Item Unit of Measure";
    begin

        IF Type <> Type::Item THEN EXIT('');
        IF "No." = '' THEN EXIT('');
        IF "Unit of Measure Code" = '' THEN EXIT('');
        IF lItemUOM.GET("No.", "Unit of Measure Code") THEN;
        EXIT(lItemUOM."Item UOM Size Code ELA");
    end;

    procedure UpdateTrackingStatus(ldecPct: Decimal; lblnItemTracking: Boolean): Code[20]
    begin

        IF lblnItemTracking THEN BEGIN
            CASE TRUE OF
                ldecPct = 100:
                    BEGIN
                        EXIT('FILLED');
                    END;

                ldecPct > 0:
                    BEGIN
                        EXIT('PARTIAL');
                    END;

                ldecPct = 0:
                    BEGIN
                        EXIT('OPEN');
                    END;

            END;
        END ELSE BEGIN
            EXIT('');
        END;
    end;

    procedure SetStyle(IdecPct: Decimal; IblnItemTracking: Boolean) Text: Text;

    begin



        IF IblnItemTracking THEN BEGIN

            CASE TRUE OF

                IdecPct = 100:

                    BEGIN

                        EXIT('Favorable');

                    END;



                IdecPct > 0:

                    BEGIN

                        EXIT('Ambiguous');

                    END;



                IdecPct = 0:

                    BEGIN

                        EXIT('Unfavorable');

                    END;



            END;

        END ELSE BEGIN

            EXIT('Standard');

        END;

    end;


    procedure SetStatus()
    var
        lblnItemTracking: Boolean;
        ldecPct: Decimal;

    begin

        TrackingStatus := '';

        ldecPct := ROUND(doTrackingExistsELA("Quantity (Base)", lblnItemTracking));
        TrackingStatus := UpdateTrackingStatus(ldecPct, lblnItemTracking);
        StyleTxt := SetStyle(ldecPct, lblnItemTracking);
    end;

    var
        gdecDeliveredPrice: Decimal;
        TrackingStatus: Code[20];
        StyleTxt: Text;
}