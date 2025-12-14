import { defineCollection, z } from 'astro:content';

const baseMeta = {
  visibility: z.string().optional(),
  use_for_ai: z.boolean().optional(),
  tags: z.array(z.string()).optional(),
  summary: z.string().optional(),
  title: z.string().optional(),
  year: z.string().optional(),
  format: z.string().optional(),
  code: z.string().optional(),
  cover_image: z.string().optional(),
  article_slug: z.string().optional()
};

const projects = defineCollection({
  schema: z.object(baseMeta)
});

const experience = defineCollection({
  schema: z.object({
    visibility: z.string().optional(),
    use_for_ai: z.boolean().optional(),
    tags: z.array(z.string()).optional(),
    title: z.string().optional()
  }).passthrough()
});

const profile = defineCollection({
  schema: z.object({
    visibility: z.string().optional(),
    use_for_ai: z.boolean().optional(),
    tags: z.array(z.string()).optional(),
    title: z.string().optional()
  }).passthrough()
});

const skills = defineCollection({
  schema: z.object({
    visibility: z.string().optional(),
    use_for_ai: z.boolean().optional(),
    tags: z.array(z.string()).optional(),
    title: z.string().optional()
  }).passthrough()
});

export const collections = {
  projects,
  experience,
  profile,
  skills
};
