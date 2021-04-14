edging = edging or class({})

function edging:GetTexture() return "alchemist_acid_spray" end -- get the icon from a different ability

function edging:IsPermanent() return true end
function edging:RemoveOnDeath() return false end
function edging:IsHidden() return self:GetStackCount() == 0 end 	-- we can hide the modifier
function edging:IsDebuff() return false end 	-- make it red or green

function edging:OnCreated(event)
	self.tick_rate = 0.2
	self.max_gain_health_pct_threshold = 10

	self.parent = self:GetParent()

	if IsClient() then return end
	self:StartIntervalThink(self.tick_rate)
end


function edging:OnIntervalThink()
	if not self.parent:IsAlive() then return end

	local edging_gain = math.min((100 - self.parent:GetHealthPercent()) / (100 - self.max_gain_health_pct_threshold), 1) * self.parent:GetLevel()
	self.total_gain = (self.total_gain or 0) + edging_gain * self.tick_rate 

	self:SetStackCount(math.floor(self.total_gain))
end

function edging:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
end

-- Stats
function edging:GetModifierBonusStats_Strength()
	return self:GetStackCount()
end 

function edging:GetModifierBonusStats_Agility()
	return self:GetStackCount()
end 

function edging:GetModifierBonusStats_Intellect()
	return self:GetStackCount()
end

function edging:OnDeath(kv)
	if IsClient() or kv.unit ~= self.parent then return end

	self.parent:EmitSound("Hero_PhantomAssassin.CoupDeGrace")
	
	local coup_pfx = ParticleManager:CreateParticle("particles/phantom_assassin_crit_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(coup_pfx, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(coup_pfx, 1, self.parent:GetAbsOrigin())
	ParticleManager:SetParticleControlOrientation(coup_pfx, 1, (-1) * self:GetParent():GetForwardVector(), self:GetParent():GetRightVector(), self:GetParent():GetUpVector())
	ParticleManager:ReleaseParticleIndex(coup_pfx)
end