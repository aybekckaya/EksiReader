import { AuthorParseError } from "../errors/app-error";
import type { AuthorBadge, AuthorProfile } from "../models/author";
import { normalizeDecodedText } from "../utils/text";
import { absoluteUrl } from "./shared/entry.parser";

class ProfileTitleHandler implements HTMLRewriterElementContentHandlers {
  found = false;
  username = "";

  element(element: Element): void {
    if (this.found) {
      return;
    }
    this.found = true;
    this.username = normalizeDecodedText(element.getAttribute("data-nick") ?? "");
  }
}

class FirstTextHandler implements HTMLRewriterElementContentHandlers {
  private collecting = false;
  private collected = false;
  private raw = "";

  element(element: Element): void {
    if (this.collecting || this.collected) {
      return;
    }
    this.collecting = true;
    element.onEndTag(() => {
      this.collecting = false;
      this.collected = true;
    });
  }

  text(text: Text): void {
    if (this.collecting) {
      this.raw += text.text;
    }
  }

  value(): string | null {
    const normalized = normalizeDecodedText(this.raw);
    return normalized === "" ? null : normalized;
  }
}

class AvatarHandler implements HTMLRewriterElementContentHandlers {
  avatarUrl: string | null = null;

  element(element: Element): void {
    if (this.avatarUrl === null) {
      this.avatarUrl = absoluteUrl(element.getAttribute("src"));
    }
  }
}

interface BadgeBuilder {
  name: string;
  description: string | null;
  imageUrl: string | null;
}

class BadgeCollector implements HTMLRewriterElementContentHandlers {
  readonly badges: AuthorBadge[] = [];
  current: BadgeBuilder | null = null;

  element(element: Element): void {
    const name = normalizeDecodedText(element.getAttribute("data-name") ?? "");
    const description = normalizeDecodedText(element.getAttribute("data-title") ?? "");
    const builder: BadgeBuilder = {
      name,
      description: description === "" ? null : description,
      imageUrl: null,
    };
    this.current = builder;
    element.onEndTag(() => {
      if (builder.name !== "") {
        this.badges.push(builder);
      }
      if (this.current === builder) {
        this.current = null;
      }
    });
  }
}

class BadgeImageHandler implements HTMLRewriterElementContentHandlers {
  constructor(private readonly collector: BadgeCollector) {}

  element(element: Element): void {
    if (this.collector.current !== null) {
      this.collector.current.imageUrl = absoluteUrl(element.getAttribute("src"));
    }
  }
}

function nullableCount(value: string | null): number | null {
  if (value === null) {
    return null;
  }
  const digits = value.replace(/[.\s]/gu, "");
  if (!/^\d+$/u.test(digits)) {
    return null;
  }
  const parsed = Number(digits);
  return Number.isSafeInteger(parsed) && parsed >= 0 ? parsed : null;
}

export async function parseAuthorProfile(html: string, authorSlug: string): Promise<AuthorProfile> {
  if (html.trim() === "") {
    throw new AuthorParseError("HTML boş.");
  }

  const title = new ProfileTitleHandler();
  const avatar = new AvatarHandler();
  const rank = new FirstTextHandler();
  const registrationDate = new FirstTextHandler();
  const entryCount = new FirstTextHandler();
  const followerCount = new FirstTextHandler();
  const followingCount = new FirstTextHandler();
  const badges = new BadgeCollector();

  try {
    const transformed = new HTMLRewriter()
      .on("#user-profile-title", title)
      .on("img.logo.avatar", avatar)
      .on("p.muted", rank)
      .on(".recorddate", registrationDate)
      .on("#entry-count-total", entryCount)
      .on("#user-follower-count", followerCount)
      .on("#user-following-count", followingCount)
      .on(".user-profile-badge-item", badges)
      .on(".user-profile-badge-item img", new BadgeImageHandler(badges))
      .transform(new Response(html));
    await transformed.arrayBuffer();
  } catch (error) {
    throw new AuthorParseError("HTMLRewriter profil HTML'ini işleyemedi.", { cause: error });
  }

  if (!title.found) {
    throw new AuthorParseError("#user-profile-title bulunamadı.");
  }
  if (title.username === "") {
    throw new AuthorParseError("#user-profile-title data-nick değeri boş.");
  }

  return {
    id: null,
    username: title.username,
    slug: authorSlug,
    avatarUrl: avatar.avatarUrl,
    rankText: rank.value(),
    registrationDateText: registrationDate.value(),
    stats: {
      entryCount: nullableCount(entryCount.value()),
      followerCount: nullableCount(followerCount.value()),
      followingCount: nullableCount(followingCount.value()),
    },
    badges: badges.badges,
  };
}
