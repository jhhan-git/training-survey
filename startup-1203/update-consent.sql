-- 불참 회신은 개인정보를 받지 않으므로 동의 없이도 저장되게 바꿉니다.
-- 수정 없이 그대로 Supabase SQL Editor 에 붙여넣고 Run 하세요. (한 번만)
alter table public.startup_attend_responses drop constraint if exists startup_attend_responses_consent_check;
alter table public.startup_attend_responses drop constraint if exists startup_attend_consent_if_attend;
alter table public.startup_attend_responses add constraint startup_attend_consent_if_attend check (consent or not attend);
notify pgrst, 'reload schema';
