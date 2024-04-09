--[Title] GLink: Links URLS in chat. | [Author] Graydon | [Version] 1.2 | [Published] 07/05/2016

--A template for the way urls are linked

addonName, GLink = ...;


-- local origChatFrame_OnHyperlinkShow = ChatFrame_OnHyperlinkShow;
-- 	ChatFrame_OnHyperlinkShow = function(...)
-- 	local chatFrame, link, text, button = ...;
-- 		if type(text) == "string" and text:match("%[How to Link%]") and not IsModifiedClick() then
-- 			return ShowLinkTip()
-- 			else if type(text) == "string" and link:match("lnkfer: ") and not IsModifiedClick() then		
-- 				url = link:gsub("lnkfer: ", "")
-- 				ChatFrame1EditBox:SetFocus()
-- 				ChatFrame1EditBox:SetText(url)
-- 				ChatFrame1EditBox:HighlightText()
-- 				--return ShowURL()
-- 			end
-- 		end
		
-- 	return origChatFrame_OnHyperlinkShow(...); 
-- end

--List of domains

domains = [[.ac.ad.ae.aero.af.ag.ai.al.am.an.ao.aq.ar.arpa.as.asia.at.au
   .aw.ax.az.ba.bb.bd.be.bf.bg.bh.bi.biz.bj.bm.bn.bo.br.bs.bt.bv.bw.by.bz.ca
   .cat.cc.cd.cf.cg.ch.ci.ck.cl.club.cm.cn.co.com.coop.cr.cs.cu.cv.cx.cy.cz.dd.de
   .dj.dk.dm.do.dz.ec.edu.ee.eg.eh.er.es.et.eu.faith.fi.firm.fj.fk.fm.fo.fr.fx.ga
   .gb.gd.ge.gf.gg.gh.gi.gl.gm.gn.gov.gp.gq.gr.gs.gt.gu.gw.gy.hk.hm.hn.hr.ht.hu
   .id.ie.il.im.in.info.int.io.iq.ir.is.it.je.jm.jo.jobs.jp.ke.kg.kh.ki.km.kn
   .kp.kr.kw.ky.kz.la.lb.lc.li.lk.lr.ls.lt.lu.lv.ly.ma.mc.md.me.media.mg.mh.mil.mk
   .ml.mm.mn.mo.mobi.mp.mq.mr.ms.mt.mu.museum.mv.mw.mx.my.mz.na.name.nato.nc
   .ne.net.nf.ng.ni.nl.no.nom.np.nr.nt.nu.nz.om.org.pa.pe.pf.pg.pk.pl.pm
   .pn.post.pr.pro.ps.pt.pw.py.qa.re.ro.ru.rw.sa.sb.sc.sd.se.sg.sh.si.sj.sk
   .sl.sm.sn.so.sr.ss.st.store.su.sv.sy.sz.tc.td.tel.tf.tg.th.tj.tk.tl.tm.tn
   .to.tools.tp.tr.travel.tt.tv.tw.tz.ua.ug.uk.um.us.uy.va.vc.ve.vg.vi.vn.vu.web.wf
   .ws.xxx.ye.yt.yu.za.zm.zr.zw]]
   
tlds = {}
for tld in domains:gmatch'%w+' do
   tlds[tld] = true
end

local function chatFilter(self,event,message,sender,...)
	messageCopy = message;
	
	--sanitise the string and sender before manipulating.
	if messageCopy:match("%d*%.%d*%.%d*%.%d*") then return false; end;
	
	if messageCopy == nil then return false; end;
	
	if string.match(messageCopy, "Hplayer:(%a*)") then
		sentFrom = string.match(messageCopy, "Hplayer:(%a+)");
		else
		if sender then
			sentFrom = string.match(sender, "(%a+)");
			end
		end
	
	--Get rid of colour code at beginning of announce and phase announce message
	if string.match(messageCopy, "cff(%x*)") then
		messageCopy = messageCopy:gsub("cff(%x*)", "");
	end
	
local protocols = {[''] = 0, ['http://'] = 0, ['https://'] = 0, ['ftp://'] = 0}
local finished = {}

--Match urls with pattern
for pos_start, url, prot, subd, tld, colon, port, slash, path in
	messageCopy:gmatch'()(([%w_.~!*:@&+$/?%%#-]-)(%w[-.%w]*%.)(%w+)(:?)(%d*)(/?)([%w_.~!*:@&+$/?%%#=-]*))'
	do	
		if protocols[prot:lower()] == (1 - #slash) * #path and not subd:find'%W%W'
			and (colon == '' or port ~= '' and port + 0 < 65536)
			and (tlds[tld:lower()] or tld:find'^%d+$' and subd:find'^%d+%.%d+%.%d+%.$'
			and max4(tld, subd:match'^(%d+)%.(%d+)%.(%d+)%.$') < 256)
		then
    finished[pos_start] = true	


		--DEFAULT_CHAT_FRAME:AddMessage("|cff2eb8b8|h[Linkifier]|r "..sentFrom.." posted an URL: \124cff29a3a3\124Hlnkfer: "..url.."\124h"..url.."\124h\124r \124cff5cd6d6\124Hitem: 28677\124h[How to Link]\124h\124r");
		return false, message.." - "..GLink_Settings.colour.."|Hlnkfer: "..url.."|h[Copy URL]|h|r",sender,...;
				--do nothing if turned off
		end
	end
	end
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", chatFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", chatFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", chatFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", chatFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", chatFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", chatFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", chatFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_WARNING", chatFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", chatFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", chatFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", chatFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_ACHIEVEMENT", chatFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", chatFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_XP_GAIN", chatFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_HONOR_GAIN", chatFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_FACTION_CHANGE", chatFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_TRADESKILLS", chatFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_OPENING", chatFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_PET_INFO", chatFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_MISC_INFO", chatFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_BG_SYSTEM_HORDE", chatFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_BG_SYSTEM_ALLIANCE", chatFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_BG_SYSTEM_NEUTRAL", chatFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_TARGETICONS", chatFilter);
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_CONVERSATION_NOTICE", chatFilter);


