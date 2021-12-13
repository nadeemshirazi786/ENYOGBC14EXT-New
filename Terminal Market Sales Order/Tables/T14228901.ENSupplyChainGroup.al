table 14228901 "EN Supply Chain Group"
{
    Caption = 'Supply Chain Group';
    LookupPageID = "EN Supply Chain Groups";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[30])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        Item: Record Item;
        ItemCategory: Record "Item Category";
        SuppyChainGroupUser: Record "EN Supply Chain Group User";
    begin
        Item.SetRange("Supply Chain Group Code ELA", Code);
        if not Item.IsEmpty then
            Error(Text001, TableCaption, Code, Item.TableCaption);

        ItemCategory.SetRange("Supply Chain Group Code ELA", Code);
        if not ItemCategory.IsEmpty then
            Error(Text001, TableCaption, Code, ItemCategory.TableCaption);

        SuppyChainGroupUser.SetCurrentKey("Supply Chain Group Code");
        SuppyChainGroupUser.SetRange("Supply Chain Group Code", Code);
        SuppyChainGroupUser.DeleteAll;
    end;

    var
        Text001: Label 'You cannot delete %1 %2 because there is at least one %3 that includes this group.';

    procedure MarkItems(var Item: Record Item)
    var
        ItemCategory: Record "Item Category";
    begin
        Item.SetRange("Supply Chain Group Code ELA", Code);
        if item.Find('-') then
            repeat
                item.Mark(true);
            until Item.Next = 0;
        item.SetRange("Supply Chain Group Code ELA");

        MarkItemCategories(ItemCategory);
        ItemCategory.MarkedOnly(true);

        Item.SetCurrentKey("Item Category Code");
        Item.SetRange("Supply Chain Group Code ELA", '');

        if ItemCategory.FindSet then
            repeat
                Item.SetRange("Item Category Code", ItemCategory.Code);
                if Item.FindSet then
                    repeat
                        item.Mark(true);
                    until Item.Next = 0;
            until ItemCategory.Next = 0;
        Item.SetRange("Item Category Code");
        Item.SetRange("Supply Chain Group Code ELA");
        Item.SetCurrentKey("No.");
    end;

    local procedure MarkItemCategories(var ItemCategory: Record "Item Category")
    var
        ItemCategory2: Record "Item Category";
    begin
        ItemCategory2.CopyFilters(ItemCategory);
        ItemCategory2 := ItemCategory;

        ItemCategory.SetFilter("Parent Category", ItemCategory.Code);
        if ItemCategory.Code = '' then
            ItemCategory.SetRange("Supply Chain Group Code ELA", Code)
        else
            ItemCategory.SetRange("Supply Chain Group Code ELA", '');
        if ItemCategory.FindSet() then
            repeat
                ItemCategory.Mark(true);
                MarkItemCategories(ItemCategory);
            until ItemCategory.Next = 0;
        ItemCategory.CopyFilters(ItemCategory2);
        ItemCategory := ItemCategory2;

    end;
}

