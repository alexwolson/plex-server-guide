# Appendix G: Sharing Plex with Friends and Family

Sharing your media server can be rewarding—giving friends and family access to your carefully curated library, simplifying streaming for less tech-savvy relatives, or just having something nice to offer people you care about. But it also comes with trade-offs worth considering before you start handing out invitations.

This appendix helps you think through whether and how to share your server.

## Why Share Your Server?

**Simplify streaming for family.** Instead of juggling Netflix, Prime, Disney+, and whatever else, your elderly parents or less technical relatives can use one app with a library you've curated for them. No more "which service has that show?" confusion.

**Share your collection.** If you've built a library of content you love, sharing it with people who'd appreciate it can be genuinely satisfying.

**Consolidate costs.** If multiple households are paying for overlapping streaming services, a shared Plex server can reduce duplication—though this depends on what content you're serving.

**Better experience for some content.** Your library might include things that aren't on any streaming service, or higher quality versions than what's available elsewhere.

## Technical Considerations

Before sharing, make sure your setup can handle it.

### Bandwidth

Your home internet upload speed is the bottleneck. Most residential connections are asymmetric—you might have 100 Mbps download but only 10-20 Mbps upload.

**Rough bandwidth requirements:**
- 1080p stream: 8-12 Mbps
- 4K stream: 20-40 Mbps (depending on bitrate)

So if you have 20 Mbps upload, you can realistically support one or two simultaneous 1080p streams before quality suffers.

**Things to consider:**
- Peak usage times—everyone wants to watch in the evening
- Your own household's usage competing with remote streams
- ISP data caps, if applicable (streaming 4K content adds up quickly)

You can limit remote stream bitrate in Plex settings ([Chapter 18](../guide/18-plex-remote-access.md)) to stretch your bandwidth further, but this may require transcoding.

### Hardware Transcoding

When you're the only user, you can optimize your library and devices for direct play. With multiple users on different devices, transcoding becomes much more likely.

**Why transcoding happens:**
- Device doesn't support the video codec (older smart TVs, some streaming sticks)
- Bandwidth-limited streams need lower bitrate versions
- Subtitles that require burning in
- User manually selects lower quality

Without hardware transcoding, a modest CPU might handle one or two simultaneous transcodes. With hardware transcoding (Intel QSV), the same hardware can handle many more. See [Chapter 1](../guide/01-hardware-and-planning.md) for hardware planning and [Appendix F](F-plex-pass-features.md) for Plex Pass requirements.

**Bottom line:** If you're sharing with others, hardware transcoding (which requires Plex Pass) becomes much more valuable.

### Storage

More users often means more content requests—especially if you enable Jellyseerr. Your library will grow faster than if you were the only one adding to it. Plan accordingly.

## Managing Requests with Jellyseerr

If you set up [Jellyseerr](../guide/13-configure-jellyseerr.md), you're giving users the ability to request content. This is convenient, but comes with trade-offs.

### The Convenience vs. Control Trade-off

**Auto-approve enabled:**
- Users get what they want without waiting
- Your library grows based on others' tastes, not just yours
- Disk fills up with content you might never watch
- Less friction for users

**Manual approval:**
- You control what gets downloaded
- You become a bottleneck ("when will my request be approved?")
- Requests pile up if you're busy
- More friction for users

**Request limits (middle ground):**
- Users can request, but only so much per week
- Prevents runaway library growth
- Still gives users some autonomy

### Things to Consider

- Are you comfortable with your library filling up with content you didn't choose?
- Do you want veto power over what gets downloaded?
- Will you actually review requests promptly, or will they sit in a queue?
- How will users feel if you reject their requests?

There's no right answer. For close family you trust, auto-approve with reasonable limits often works well. For broader sharing, manual approval or strict limits might make more sense.

## The "Family IT Support" Reality

Once you share your server, you've signed up for some level of ongoing support. Be realistic about what this means.

### You're Now a Sysadmin

Expect to deal with:
- "It's not working" messages (often at inconvenient times)
- Helping people set up Plex on new devices
- Explaining why the show they want isn't available yet
- Troubleshooting playback issues that turn out to be their WiFi
- Questions about how to use the apps
- Requests for features Plex doesn't have

Some of this is fine. Some of it can become exhausting if you're not prepared for it.

### Setting Expectations

Be clear upfront about what you're offering:
- This isn't Netflix. Downtime happens. Content isn't instant.
- You're doing this as a favor, not running a commercial service.
- Response time for support may vary based on your schedule.

Consider a simple group chat or status page where you can post announcements ("Server down for maintenance tonight" or "Added a bunch of new movies").

### Tips for Maintaining Sanity

- **Set boundaries.** You don't have to respond to support requests at 10pm.
- **Create a simple FAQ.** Common issues (how to log in, what devices work best, why something is buffering) can often be answered once and shared.
- **Consider your user list carefully.** Not everyone needs access. It's okay to keep it small.
- **Remember you can revoke access.** If someone is causing problems or being demanding, it's your server.

## Legal Considerations

This guide doesn't tell you what to download or where to get it. But it's worth pausing on one point.

For some people, there's a meaningful difference between downloading content for personal use versus distributing it to others. Sharing your server with friends and family could be seen as crossing that line, depending on your perspective and jurisdiction.

This isn't legal advice—just something to think about before you start handing out access. You're the one running the server. What's on it and who accesses it is your responsibility.

## Privacy and Security Considerations

A few things to be aware of:

- **Users can see your server name** and potentially your watch history (depending on Plex settings)
- **Library names may reveal content**—think about what "Linux ISOs" or other creative names actually communicate
- **Remote access requires port forwarding**—make sure you've followed the security guidance in the main guide
- **Users see each other's requests** in Jellyseerr (if enabled)—this might matter depending on your social dynamics

## Practical Setup Checklist

If you've decided to share:

- [ ] Verify your upload bandwidth can support your intended users
- [ ] Enable hardware transcoding ([Appendix F](F-plex-pass-features.md))
- [ ] Configure remote stream bitrate limits ([Chapter 18](../guide/18-plex-remote-access.md))
- [ ] Set up Jellyseerr with appropriate permissions ([Chapter 13](../guide/13-configure-jellyseerr.md))
- [ ] Decide on request limits and approval workflow
- [ ] Share libraries with users (Plex Settings > Users & Sharing)
- [ ] Brief your users on how to use Plex and Jellyseerr
- [ ] Set expectations about support and availability

## When Sharing Works Best

Sharing tends to work well when:

- You're sharing with a small group (household plus a few close friends or family)
- Your users appreciate what you're offering and don't treat it like a commercial streaming service
- Your internet connection has enough upload bandwidth
- Your hardware can handle the transcoding load
- You're comfortable with some level of ongoing support responsibility

## When to Reconsider

Sharing might not be right for you if:

- Your internet can't support multiple streams reliably
- You're spending more time on support than enjoying the server yourself
- Storage costs are getting out of hand due to request volume
- It's creating friction in relationships (entitlement, complaints, demands)
- You're uncomfortable with the legal or ethical implications

There's nothing wrong with keeping your server private. It's yours.
