
local AddOnName, MoveAny = ...

local btnsize = 36

function MoveAny:InitBuffBar()
	MABuffBar = CreateFrame( "Frame", "MABuffBar", UIParent )
	if BuffFrame then
		MABuffBar:SetPoint( "TOPRIGHT", UIParent, "TOPRIGHT", -165, -32 )
	else
		MABuffBar:SetPoint( "CENTER", UIParent, "CENTER", 0, 0 )
	end
	if MoveAny:IsEnabled( "DEBUFFS", false ) == true then
		MABuffBar:SetSize( btnsize * 8, btnsize * 3 )
	else
		MABuffBar:SetSize( btnsize * 8, btnsize * 6 )	
	end

	hooksecurefunc( BuffFrame, "SetPoint", function( self, ... )
		if self.masetpoint_buff then return end
		self.masetpoint_buff = true

		self:SetMovable( true )
		if self.SetUserPlaced then
			self:SetUserPlaced( false )
		end
		
		self:SetParent( MABuffBar )
		self:ClearAllPoints()
		self:SetPoint( "TOPRIGHT", MABuffBar, "TOPRIGHT", 0, 0 )
		
		self.masetpoint_buff = false
	end )
	BuffFrame:ClearAllPoints()
	BuffFrame:SetPoint( "TOPRIGHT", MABuffBar, "TOPRIGHT", 0, 0 )

	if false then
		BuffFrame.t = BuffFrame:CreateTexture()
		BuffFrame.t:SetAllPoints( BuffFrame )
		BuffFrame.t:SetColorTexture( 0, 1, 1, 1 )

		MABuffBar.t = MABuffBar:CreateTexture()
		MABuffBar.t:SetAllPoints( MABuffBar )
		MABuffBar.t:SetColorTexture( 1, 0, 0, 0.2 )
	end
end
