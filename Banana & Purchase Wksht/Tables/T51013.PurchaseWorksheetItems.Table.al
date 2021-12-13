table 51013 "Purchase Worksheet Items"
{
    Caption = 'Purchase Worksheet Columns';
    DrillDownPageID = "Purchase Lines";
    LookupPageID = "Purchase Lines";
    PasteIsValid = false;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'No.';

            trigger OnValidate()
            var
                ICPartner: Record "IC Partner";
                ItemCrossReference: Record "Item Cross Reference";
                PrepmtMgt: Codeunit "Prepayment Mgt.";
            begin
            end;
        }
        field(2; "Item No."; Code[20])
        {
            TableRelation = Item;
        }
        field(3; "Variant Code"; Code[10])
        {
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
            MaintainSIFTIndex = false;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        PurchCommentLine: Record "Purch. Comment Line";
        lrecPurchLine: Record "Purchase Line";
    begin
    end;

    trigger OnInsert()
    var
        lrecPurchLine: Record "Purchase Line";
    begin
    end;

    var
        Text000: Label 'You cannot rename a %1.';
        Text001: Label 'You cannot change %1 because the order line is associated with sales order %2.';
        Text002: Label 'Prices including VAT cannot be calculated when %1 is %2.';
        Text003: Label 'You cannot purchase resources.';
        Text004: Label 'must not be less than %1';
        Text006: Label 'You cannot invoice more than %1 units.';
        Text007: Label 'You cannot invoice more than %1 base units.';
        Text008: Label 'You cannot receive more than %1 units.';
        Text009: Label 'You cannot receive more than %1 base units.';
        Text010: Label 'You cannot change %1 when %2 is %3.';
        Text011: Label ' must be 0 when %1 is %2';
        Text012: Label 'must not be specified when %1 = %2';
        Text014: Label 'Change %1 from %2 to %3?';
        Text016: Label '%1 is required for %2 = %3.';
        Text017: Label '\The entered information will be disregarded by warehouse operations.';
        Text018: Label '%1 %2 is earlier than the work date %3.';
        Text020: Label 'You cannot return more than %1 units.';
        Text021: Label 'You cannot return more than %1 base units.';
        Text022: Label 'You cannot change %1, if item charge is already posted.';
        Text023: Label 'You cannot change the %1 when the %2 has been filled in.';
        Text029: Label 'must be positive.';
        Text030: Label 'must be negative.';
        Text031: Label 'You cannot define item tracking on this line because it is linked to production order %1.';
        Text032: Label '%1 must not be greater than %2.';
        Text033: Label 'Warehouse ';
        Text034: Label 'Inventory ';
        Text035: Label '%1 units for %2 %3 have already been returned or transferred. Therefore, only %4 units can be returned.';
        Text036: Label 'You must cancel the existing approval for this document to be able to change the %1 field.';
        Text037: Label 'cannot be %1.';
        Text038: Label 'cannot be less than %1.';
        Text039: Label 'cannot be more than %1.';
        Text99000000: Label 'You cannot change %1 when the purchase order is associated to a production order.';
        Text042: Label 'You cannot return more than the %1 units that you have received for %2 %3.';
        Text043: Label 'must be positive when %1 is not 0.';
        Text044: Label 'You cannot change %1 because this purchase order is associated with %2 %3.';
        Text1020002: Label 'Operation cancelled to preserve Tax Differences.';
        Text1020001: Label 'This operation will remove the Tax Differences that were previously entered. Are you sure you want to continue?';
        Text1020000: Label 'You must reopen the document since this will affect Sales Tax.';
        USText001: Label 'You have added a %1, which will result in a Tax Entry being posted to record the amount of Sales Tax you will owe your Province as a result of this purchase. Are you sure you want to do this?';
        Text1020003: Label 'The %1 field in the %2 used on the %3 must match the %1 field in the %2 used on the %4.';
        Text100: Label 'Acquisition can only be selected for type Fixed Asset or G/L Account.';
        gcon000: Label 'You cannot enter dimensions values on this line.\The Item Charge is set to inherit assignment dimensions.';
        gjfText000: Label 'Pallet Tracking exists for the Purchase Line.\You must delete the Pallet Tracking before deleting or modifying the Purchase Line.';
        gjfText001: Label 'Update Quantity with Qty. To Release form the Blanket Order?';
        gjfText002: Label 'Quantity (Base) cannot be more than %1, based on the Blanket Order constraints.';
        gjfText004: Label 'Variable weight items cannot have multiple receipts. Enter additional lines if necessary.';
        gjftext033: Label 'You changed the %1 when Lock Pricing is set. \Confirm pricing is correct.';
}

