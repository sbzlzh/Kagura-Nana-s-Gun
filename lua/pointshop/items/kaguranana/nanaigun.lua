ITEM.Name = 'nanaigun'
ITEM.Price = 2000
ITEM.Model = 'models/weapons/w_smg1.mdl'
ITEM.WeaponClass = 'weapon_nanaigun'
ITEM.SingleUse = true
ITEM.NoPreview = true

function ITEM:OnBuy(ply)
	ply:Give(self.WeaponClass)
	ply:SelectWeapon(self.WeaponClass)
end

function ITEM:OnSell(ply)
	ply:StripWeapon(self.WeaponClass)
end