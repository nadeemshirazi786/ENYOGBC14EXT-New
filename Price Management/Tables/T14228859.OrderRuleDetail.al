/// <summary>
/// Table EN Order Rule Detail (ID 14228859).
/// </summary>
table 14228859 "EN Order Rule Detail"
{

    Caption = 'Order Rule Detail';

    fields
    {
        field(1; "Sales Code"; Code[20])
        {

            TableRelation = if ("Sales Type"=const(Customer)) Customer
            else if("Sales Type"=const("Order Rule Group")) "EN Order Rule Group";
            trigger OnValidate()
            begin
                
                IF "Sales Code" <> '' THEN BEGIN
                  CASE "Sales Type" OF
                    "Sales Type"::"All Customers":
                      BEGIN
                        ERROR(gconText002,FIELDCAPTION("Sales Code"));
                      END;
                  END;
                  "Ship-To Address Code" := '';
                END;
                
            end;
 
        }
        field(2;"Ship-To Address Code";Code[10])
        {
            TableRelation = IF ("Sales Type"=CONST(Customer)) "Ship-to Address".Code WHERE ("Customer No."=FIELD("Sales Code"));
        }
        field(3;"Item Type";Enum "EN Item Type Order Rule")
        {
            //ptionCaption = 'Item No.,Item Category,Combination';
            //OptionMembers = "Item No.","Item Category",Combination;
            
            trigger OnValidate()
            begin
                IF "Item Type" <> xRec."Item Type" THEN BEGIN
                  "Item Ref. No." := '';
                END;

                //CLEAR(Status);
            end;
        }
        field(4;"Item Ref. No.";Code[20])
        {
            Caption = 'Item Ref. No.';
            TableRelation = IF ("Item Type"=CONST("Item No.")) Item ELSE IF ("Item Type"=CONST("Item Category")) "Item Category";
        }
        field(5;"Start Date";Date)
        {
        }
        field(6;"Unit of Measure Code";Code[10])
        {
            TableRelation = IF ("Item Type"=CONST("Item No.")) "Item Unit of Measure".Code WHERE ("Item No."=FIELD("Item Ref. No."))
                            ELSE "Unit of Measure".Code;
        }
        field(10;"Sales Type";Enum "EN Sales Type Order Rule")
        {
            Caption = 'Sales Type';
            //OptionCaption = 'Customer,Order Rule Group,All Customers';
            //OptionMembers = Customer,"Order Rule Group","All Customers";

            trigger OnValidate()
            begin
                IF "Sales Type" <> xRec."Sales Type" THEN BEGIN
                  VALIDATE("Sales Code",'');
                  VALIDATE("Ship-To Address Code",'');
                END;
            end;
        }
        field(20;"Min. Order Qty.";Decimal)
        {
            DecimalPlaces = 0:5;
            MinValue = 0;
        }
        field(21;"Order Multiple";Decimal)
        {
            DecimalPlaces = 0:0;
            MinValue = 0;

            trigger OnValidate()
            var
                lconError001: Label 'You cannot fill in Order Multiple cor combination lines.';
            begin
                IF "Item Type" = "Item Type" :: Combination THEN BEGIN
                  ERROR(lconError001);
                END;
            end;
        }
        field(22;"End Date";Date)
        {
        }
        field(25;Status;Option)
        {
            OptionMembers = Allowed,"Not Allowed";

            trigger OnValidate()
            begin
                IF Status = Status::"Not Allowed" THEN BEGIN
                  IF "Item Type" = "Item Type"::Combination THEN
                    FIELDERROR("Item Type");
                END;
            end;
        }
        field(26;"Reason Code";Code[10])
        {
            TableRelation = "Reason Code".Code;
        }
        field(27;"Date Filter";Date)
        {
            FieldClass = FlowFilter;
        }
        field(28;"Min. Qty. Filter";Decimal)
        {
            FieldClass = FlowFilter;
        }
        field(29;"Sales Type Filter";Option)
        {
            Caption = 'Sales Type Filter';
            
            FieldClass = FlowFilter;
            OptionCaption = 'Customer,Order Rule Group,All Customers';
            OptionMembers = Customer,"Order Rule Group","All Customers";
        }
        field(30;"Sales Code Filter";Code[20])
        {
            Caption = 'Sales Code Filter';
            
            FieldClass = FlowFilter;
            TableRelation = IF ("Sales Type"=CONST("Order Rule Group")) "EN Order Rule Group"
                            ELSE IF ("Sales Type"=CONST(Customer)) Customer;
        }
        field(31;"Item Type Filter";Option)
        {
            Caption = 'Item Type Filter';
            FieldClass = FlowFilter;
            OptionCaption = 'Item No.,Item Category,Combination';
            OptionMembers = "Item No.","Item Category",Combination;
        }
        field(32;"Item Ref. No. Filter";Code[20])
        {
            Caption = 'Item Ref. No. Filter';
            
            FieldClass = FlowFilter;
        }
    }

    keys
    {
        key(Key1;"Sales Type","Sales Code","Ship-To Address Code","Item Type","Item Ref. No.","Start Date","Unit of Measure Code")
        {
            Clustered = true;
        }
        key(Key2;"Sales Type","Sales Code","Ship-To Address Code","Item Type","Unit of Measure Code","Min. Order Qty.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        lrecOrderRuleDetailLine: Record "EN Order Rule Detail Line";
    begin
        lrecOrderRuleDetailLine.SETRANGE("Sales Type","Sales Type");
        lrecOrderRuleDetailLine.SETRANGE("Sales Code","Sales Code");
        lrecOrderRuleDetailLine.SETRANGE("Ship-To Address Code","Ship-To Address Code");
        lrecOrderRuleDetailLine.SETRANGE("Item Type","Item Type");
        lrecOrderRuleDetailLine.SETRANGE("Item Ref. No.","Item Ref. No.");
        lrecOrderRuleDetailLine.SETRANGE("Start Date","Start Date");
        lrecOrderRuleDetailLine.SETRANGE("Unit of Measure Code","Unit of Measure Code");
        IF lrecOrderRuleDetailLine.FIND('-') THEN BEGIN
          lrecOrderRuleDetailLine.DELETEALL(TRUE);
        END;
    end;

    trigger OnInsert()
    begin
        IF "Sales Type" = "Sales Type"::"All Customers" THEN
          "Sales Code" := ''
        ELSE
          TESTFIELD("Sales Code");
    end;

    trigger OnRename()
    var
        lrecOrderRuleDetailLine: Record "EN Order Rule Detail Line";
        lrecOrderRuleDetailLine2: Record "EN Order Rule Detail Line";
    begin
        IF "Sales Type" <> "Sales Type"::"All Customers" THEN
          TESTFIELD("Sales Code");
        lrecOrderRuleDetailLine.SETRANGE("Sales Type",xRec."Sales Type");
        lrecOrderRuleDetailLine.SETRANGE("Sales Code",xRec."Sales Code");
        lrecOrderRuleDetailLine.SETRANGE("Ship-To Address Code",xRec."Ship-To Address Code");
        lrecOrderRuleDetailLine.SETRANGE("Item Type",xRec."Item Type");
        lrecOrderRuleDetailLine.SETRANGE("Item Ref. No.",xRec."Item Ref. No.");
        lrecOrderRuleDetailLine.SETRANGE("Start Date",xRec."Start Date");
        lrecOrderRuleDetailLine.SETRANGE("Unit of Measure Code",xRec."Unit of Measure Code");
        IF lrecOrderRuleDetailLine.FIND('-') THEN REPEAT
          lrecOrderRuleDetailLine2.GET(lrecOrderRuleDetailLine."Sales Type",
                                       lrecOrderRuleDetailLine."Sales Code",
                                       lrecOrderRuleDetailLine."Ship-To Address Code",
                                       lrecOrderRuleDetailLine."Item Type",
                                       lrecOrderRuleDetailLine."Item Ref. No.",
                                       lrecOrderRuleDetailLine."Start Date",
                                       lrecOrderRuleDetailLine."Unit of Measure Code",
                                       lrecOrderRuleDetailLine."Item No.");
          lrecOrderRuleDetailLine2.RENAME("Sales Type",
                                          "Sales Code",
                                          "Ship-To Address Code",
                                          "Item Type",
                                          "Item Ref. No.",
                                          "Start Date",
                                          "Unit of Measure Code",
                                          lrecOrderRuleDetailLine."Item No.");
        UNTIL lrecOrderRuleDetailLine.NEXT = 0;
    end;

    var
        gconText001: Label 'Unit Price cannot be 0 for Sales Return No. %1, Line No. %4.';
        gconText002: Label '%1 must be blank.';
}

