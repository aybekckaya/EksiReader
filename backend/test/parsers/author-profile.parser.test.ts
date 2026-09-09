import { beforeAll, describe, expect, it } from "vitest";
import { AuthorParseError } from "../../src/errors/app-error";
import type { AuthorProfile } from "../../src/models/author";
import { parseAuthorProfile } from "../../src/parsers/author-profile.parser";
import authorProfileHtml from "../fixtures/author-profile.html?raw";

describe("parseAuthorProfile", () => {
  let parsed: AuthorProfile;

  beforeAll(async () => {
    parsed = await parseAuthorProfile(authorProfileHtml, "sakarninja");
  });

  it("username'i data-nick'ten parse eder ve whitespace normalize eder", () => {
    expect(parsed.username).toBe("sakarninja");
  });

  it("route author slug'ını korur", () => {
    expect(parsed.slug).toBe("sakarninja");
  });

  it("profile request'te bilinmeyen author id için null döner", () => {
    expect(parsed.id).toBeNull();
  });

  it("protocol-relative avatar URL'yi HTTPS'e çevirir", () => {
    expect(parsed.avatarUrl).toBe("https://ekstat.com/img/default-profile-picture-light.svg");
  });

  it("absolute avatar URL'yi korur", async () => {
    const result = await parseAuthorProfile(
      authorProfileHtml.replace(
        "//ekstat.com/img/default-profile-picture-light.svg",
        "https://img.ekstat.com/profiles/sakarninja.jpg",
      ),
      "sakarninja",
    );
    expect(result.avatarUrl).toBe("https://img.ekstat.com/profiles/sakarninja.jpg");
  });

  it("avatar yoksa null döner", async () => {
    const result = await parseAuthorProfile(
      authorProfileHtml.replace(/<img\s+class="logo avatar"[\s\S]*?alt="sakarninja"\s*>/u, ""),
      "sakarninja",
    );
    expect(result.avatarUrl).toBeNull();
  });

  it("rankText'i semantik parçalamadan ve whitespace normalize ederek parse eder", () => {
    expect(parsed.rankText).toBe("hippi (428)");
  });

  it("registrationDateText'i normalize eder", () => {
    expect(parsed.registrationDateText).toBe("mayıs 2001");
  });

  it("noktalı entryCount değerini parse eder", () => {
    expect(parsed.stats.entryCount).toBe(2720);
  });

  it("followerCount değerini parse eder", () => {
    expect(parsed.stats.followerCount).toBe(19);
  });

  it("gerçek sıfır followingCount değerini korur", () => {
    expect(parsed.stats.followingCount).toBe(0);
  });

  it("badge adını parse eder", () => {
    expect(parsed.badges[0]?.name).toBe("azimli");
  });

  it("badge açıklamasını parse eder", () => {
    expect(parsed.badges[0]?.description).toBe("en az 1000 entry girmiş");
  });

  it("badge image URL'sini parse eder", () => {
    expect(parsed.badges[0]?.imageUrl).toBe("https://cdn.eksisozluk.com/badges/azimli.png");
  });

  it("protocol-relative badge image URL'sini normalize eder", () => {
    expect(parsed.badges[1]?.imageUrl)
      .toBe("https://cdn.eksisozluk.com/badges/bilgi-kupu.png");
  });

  it("birden fazla badge parse eder", () => {
    expect(parsed.badges).toHaveLength(2);
  });

  it("badge listesi yoksa boş array döner", async () => {
    const result = await parseAuthorProfile(
      authorProfileHtml.replace(/<section class="badges">[\s\S]*?<\/section>/u, ""),
      "sakarninja",
    );
    expect(result.badges).toEqual([]);
  });

  it("stats alanları eksikse sıfır uydurmak yerine null döner", async () => {
    const html = authorProfileHtml
      .replace('id="entry-count-total"', 'id="old-entry-count-total"')
      .replace('id="user-follower-count"', 'id="old-user-follower-count"')
      .replace('id="user-following-count"', 'id="old-user-following-count"');
    const result = await parseAuthorProfile(html, "sakarninja");
    expect(result.stats).toEqual({ entryCount: null, followerCount: null, followingCount: null });
  });

  it("profile title yoksa kontrollü parse error verir", async () => {
    await expect(parseAuthorProfile(
      authorProfileHtml.replace('id="user-profile-title"', 'id="old-profile-title"'),
      "sakarninja",
    )).rejects.toBeInstanceOf(AuthorParseError);
  });

  it("data-nick boşsa kontrollü parse error verir", async () => {
    await expect(parseAuthorProfile(
      authorProfileHtml.replace('data-nick="  sakarninja  "', 'data-nick="   "'),
      "sakarninja",
    )).rejects.toBeInstanceOf(AuthorParseError);
  });
});
